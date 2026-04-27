from fastapi import APIRouter, Depends, HTTPException, Query
from typing import List, Optional
from sqlalchemy import and_, asc, desc
from sqlalchemy.orm import Session, joinedload, selectinload
from database import get_db
from middleware.optional_auth import try_get_user_id_from_token
from models.user_favorite import UserFavorite
from pydantic_schemas.products.product_request import ProductRequest
from pydantic_schemas.products.product_list_response import ProductListResponse
from pydantic_schemas.products.product_details.product_detail import ProductDetailResponse
from pydantic_schemas.products.filter_item import FilterItem
from pydantic_schemas.products.product_details.color_variant import ColorVariantSchema
from pydantic_schemas.products.product_details.image_detail import ImageDetailSchema
from pydantic_schemas.products.product_details.variant_detail import VariantDetailSchema
from models.products.menu_category import MenuCategory
from models.products.product import Product
from models.products.product_color import ProductColor
from models.products.product_variant import ProductVariant
from utils.product_route_utils import execute_search, format_products, get_available_filters, get_products_for_category, parse_search_query

router = APIRouter()

## lst all product sby categories, returns filters too
@router.get("/list", response_model=ProductListResponse)
def list_products(
    menu_category_id: int,
    subcategory_id: Optional[int] = None,
    color_ids: List[int] = Query(default=[]),
    size_ids: List[int] = Query(default=[]),   
    brand_ids: List[int] = Query(default=[]), 
    sort_by: str = "newest",
    page: int = 1,
    page_size: int = 20,
    db: Session = Depends(get_db)
):
    params = ProductRequest(
        menu_category_id=menu_category_id,
        subcategory_id=subcategory_id,
        color_ids=color_ids,
        size_ids=size_ids,
        brand_ids=brand_ids,
        sort_by=sort_by,
        page=page,
        page_size=page_size
    )

    if not db.query(MenuCategory).filter_by(id=params.menu_category_id).first():
        raise HTTPException(status_code=404, detail="Menu category not found")

    base_query = db.query(Product).filter(
        Product.is_active == True,
        Product.menu_category_id == menu_category_id)

    filters = get_available_filters(db, base_query, params.menu_category_id)

    products = get_products_for_category(base_query, params)

    return ProductListResponse(
        products=products,
        colors=filters["colors"],
        subcategories=filters["subcategories"],
        sizes=filters["sizes"],
        brands=filters['brands']
    )

@router.get("/search", response_model=ProductListResponse)
async def search(
    q: Optional[str] = None,
    gender: str = "women",
    menu_category_id: Optional[int] = None,
    search_id: Optional[str] = None,
    color_ids: List[int] = Query(default=[]),
    size_ids: List[int] = Query(default=[]),
    brand_ids: List[int] = Query(default=[]),
    sort_by: str = "newest",
    page: int = 1,
    page_size: int = 20,
    db: Session = Depends(get_db)
):

    if not q:
        raise HTTPException(status_code=400, detail="Query required")

    query_text = q

    extracted_metadata = await parse_search_query(
        db=db,
        query_text=query_text,
        gender=gender,
        menu_category_id=menu_category_id
    )

    products, filters = await execute_search(
        db=db,
        query_text=query_text,
        gender=gender,
        metadata=extracted_metadata,
        color_ids=color_ids,
        size_ids=size_ids,
        brand_ids=brand_ids,
        sort_by=sort_by,
        page=page,
        page_size=page_size
    )

    return ProductListResponse(
        products=format_products(products, color_ids),
        colors=filters["colors"],
        sizes=filters["sizes"],
        brands=filters["brands"],
        subcategories=[] 
    )

# return specific products by ids, used for "show all" in chat
@router.get("/by_ids", response_model=ProductListResponse)
def products_by_ids(
    product_ids: List[int] = Query(default=[]),
    color_ids: List[int] = Query(default=[]),
    size_ids: List[int] = Query(default=[]),
    brand_ids: List[int] = Query(default=[]),
    sort_by: str = "newest",
    page: int = 1,
    page_size: int = 20,
    db: Session = Depends(get_db),
):
    if not product_ids:
        return ProductListResponse(products=[], colors=[], subcategories=[], sizes=[], brands=[])

    filters_base_query = (
        db.query(Product)
        .filter(Product.is_active == True, Product.id.in_(product_ids))
    )
    filters = get_available_filters(db, filters_base_query, 0)

    query = (
        db.query(Product)
        .options(
            joinedload(Product.brand),
            joinedload(Product.category),
            selectinload(Product.product_colors).joinedload(ProductColor.color_filter),
            selectinload(Product.images),
        )
        .filter(Product.is_active == True, Product.id.in_(product_ids))
    )

    if brand_ids:
        query = query.filter(Product.brand_id.in_(brand_ids))

    if color_ids:
        query = query.filter(
            Product.product_colors.any(
                and_(
                    ProductColor.color_filter_id.in_(color_ids),
                    ProductColor.is_active == True,
                )
            )
        )

    if size_ids:
        query = query.filter(
            Product.product_colors.any(
                ProductColor.variants.any(
                    and_(
                        ProductVariant.size_id.in_(size_ids),
                        ProductVariant.is_active == True,
                    )
                )
            )
        )

    if sort_by == "chat_order":
        matching = query.all()
        by_id = {p.id: p for p in matching}
        ordered = [by_id[i] for i in product_ids if i in by_id]
        offset = (page - 1) * page_size
        products = ordered[offset : offset + page_size]
    elif sort_by == "price_asc":
        query = query.order_by(asc(Product.price))
        offset = (page - 1) * page_size
        products = query.offset(offset).limit(page_size).all()
    elif sort_by == "price_desc":
        query = query.order_by(desc(Product.price))
        offset = (page - 1) * page_size
        products = query.offset(offset).limit(page_size).all()
    else:
        query = query.order_by(desc(Product.created_at))
        offset = (page - 1) * page_size
        products = query.offset(offset).limit(page_size).all()

    return ProductListResponse(
        products=format_products(products, color_ids),
        colors=filters["colors"],
        subcategories=[],
        sizes=filters["sizes"],
        brands=filters["brands"],
    )

# get all product details
@router.get("/{product_id}", response_model=ProductDetailResponse)
def get_product_detail(
    product_id: int,
    db: Session = Depends(get_db),
    user_id: Optional[str] = Depends(try_get_user_id_from_token),
):
    product = db.query(Product).options(
        joinedload(Product.brand),
        selectinload(Product.product_colors).options(
            selectinload(ProductColor.images),
            selectinload(ProductColor.variants).joinedload(ProductVariant.size)
        )
    ).filter(
        Product.id == product_id, 
        Product.is_active == True
    ).first()

    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    favorited: Optional[bool] = None
    if user_id is not None:
        favorited = (
            db.query(UserFavorite)
            .filter(
                UserFavorite.user_id == user_id,
                UserFavorite.product_id == product_id,
            )
            .first()
        ) is not None

    color_schemas = []
    for color in product.product_colors:
        if not color.is_active:
            continue

        variant_list = [
            VariantDetailSchema(
                id=v.id,
                size=FilterItem(id=v.size.id, name=v.size.code),
                price=v.price if v.price is not None else product.price,
                availability=v.availability
            )
            for v in color.variants if v.is_active
        ]

        if variant_list:
            color_schemas.append(ColorVariantSchema(
                id=color.id,
                name=color.name,
                images=[ImageDetailSchema(url=img.url) for img in color.images if img.is_active],
                variants=variant_list
            ))

    return ProductDetailResponse(
        id=product.id,
        product_id=product.product_id,
        name=product.name,
        description=product.description,
        price=product.price,
        brand=product.brand.name,
        url=product.url,
        colors=color_schemas,
        favorited=favorited,
    )

