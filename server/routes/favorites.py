from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import desc
from sqlalchemy.orm import Session
from database import get_db
from middleware.auth_middleware import auth_middleware
from models.user_favorite import UserFavorite
from models.products.product import Product
from pydantic_schemas.favorites.price_drop_alerts_count_response import (
    PriceDropAlertsCountResponse,
)
from pydantic_schemas.products.product_list_response import ProductListResponse
from utils.product_route_utils import get_available_filters, format_products

router = APIRouter()


@router.get("/price-drop-alerts", response_model=PriceDropAlertsCountResponse)
def get_price_drop_alerts(
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware),
):
    user_id = user_dict["uid"]
    affected = 0

    favorites = (
        db.query(UserFavorite)
        .join(Product)
        .filter(
            UserFavorite.user_id == user_id,
            UserFavorite.notified == False,
            Product.is_active == True,  
        )
        .all()
    )

    for fav in favorites:
        product = fav.product
        if not product or product.price is None:
            continue

        current_p = float(product.price)
        original_p = float(fav.price_at_add)

        if current_p < original_p:
            affected += 1

        fav.notified = True

    db.commit()
    return PriceDropAlertsCountResponse(affected_count=affected)


# check if product is already favorited by user
@router.get("/exists/{product_id}")
def check_favorite(
    product_id: int,
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware),
):
    user_id = user_dict["uid"]
    check_if_exists = (
        db.query(UserFavorite)
        .filter(
            UserFavorite.user_id == user_id,
            UserFavorite.product_id == product_id,
        )
        .first()
    )
    return {"favorited": check_if_exists is not None}


# get all favorited products
@router.get("", response_model=ProductListResponse)
def list_favorites(
    page: int = 1,
    page_size: int = 40,
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware),
):
    user_id = user_dict["uid"]
    offset = (page - 1) * page_size
    rows = (
        db.query(UserFavorite, Product)
        .join(Product, UserFavorite.product_id == Product.id)
        .filter(
            UserFavorite.user_id == user_id,
            Product.is_active == True,  
        )
        .order_by(desc(UserFavorite.created_at), desc(UserFavorite.id))
        .offset(offset)
        .limit(page_size)
        .all()
    )
    if not rows:
        return ProductListResponse(
            products=[],
            colors=[],
            subcategories=[],
            sizes=[],
            brands=[],
        )

    products = [p for _, p in rows]
    filters_base = (
        db.query(Product)
        .filter(
            Product.is_active == True, 
            Product.id.in_([p.id for p in products]),
        )
    )
    filters = get_available_filters(db, filters_base, 0)
    return ProductListResponse(
        products=format_products(products, []),
        colors=filters["colors"],
        subcategories=[],
        sizes=filters["sizes"],
        brands=filters["brands"],
    )


# create row in favorites table if it does not exist
@router.post("/{product_id}", status_code=201)
def add_favorite(
    product_id: int,
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware),
):
    user_id = user_dict["uid"]
    product = (
        db.query(Product)
        .filter(Product.id == product_id, Product.is_active == True) 
        .first()
    )
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    check_if_exists = (
        db.query(UserFavorite)
        .filter(
            UserFavorite.user_id == user_id,
            UserFavorite.product_id == product_id,
        )
        .first()
    )
    if check_if_exists:
        return {"ok": True, "id": check_if_exists.id}
    p = float(product.price)
    row = UserFavorite(
        user_id=user_id,
        product_id=product_id,
        price_at_add=p,
        current_price=p,
        notified=True,
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return {"ok": True, "id": row.id}


@router.delete("/{product_id}", status_code=204)
def remove_favorite(
    product_id: int,
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware),
):
    user_id = user_dict["uid"]
    favorite_product = (
        db.query(UserFavorite)
        .filter(
            UserFavorite.user_id == user_id,
            UserFavorite.product_id == product_id,
        )
        .delete()
    )
    if not favorite_product:
        raise HTTPException(status_code=404, detail="Favorite not found")
    db.commit()
