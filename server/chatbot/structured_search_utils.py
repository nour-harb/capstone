from typing import Dict, List, Optional
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import and_, func, or_
from models.products.brand import Brand
from models.products.color_filters import ColorFilter
from models.products.menu_category import MenuCategory
from models.products.product import Product
from models.products.product_color import ProductColor
from models.products.product_variant import ProductVariant
from models.products.size_master import SizeMaster
from models.products.subcategory import Subcategory

USD_TO_LBP = 89000

def resolve_color_filter_id_by_name(db: Session, color_name: str) -> Optional[int]:
    """Match the same case-insensitive name as structured_search_logic color join."""
    if not (color_name or "").strip():
        return None
    row = (
        db.query(ColorFilter)
        .filter(func.lower(ColorFilter.name) == color_name.strip().lower())
        .first()
    )
    return int(row.id) if row is not None else None


def resolve_size_id_by_code(db: Session, code: str) -> Optional[int]:
    if not (code or "").strip():
        return None
    row = (
        db.query(SizeMaster)
        .filter(func.lower(SizeMaster.code) == code.strip().lower())
        .first()
    )
    out = int(row.id) if row is not None else None
    return out


class GetStoreOptionsInput(BaseModel):
    gender: str = Field(
        ...,
        description=(
            "Catalog gender for this shopping turn (must match a DB value such as woman/man). "
            "Infer from the user; if unclear, default to woman."
        ),
    )


class StructuredSearchInput(BaseModel):
    category: Optional[str] = Field(None, description="The category name (e.g., 'shoes', 'dresses')")
    subcategory: Optional[str] = Field(
        None,
        description=(
            "Subcategory from GetStoreOptions for this category. Omit when the user did not specify a cut/type — "
            "search broader without it."
        ),
    )
    color: Optional[str] = Field(
        None,
        description=(
            "Optional. When the user specified or implied a color: exactly one name from the Colors list in the "
            "latest GetStoreOptions for this gender; map informal shades to the closest list entry. "
            "Omit when they did not mention color — do not invent a filter."
        ),
    )
    size: Optional[str] = Field(
        None,
        description=(
            "Optional. When the user specified a size: exactly one `code` from the Sizes list in the latest "
            "GetStoreOptions for this gender; map casual wording (S/M/L, EU 40) to the closest list entry. "
            "Omit when they did not mention size — do not invent a filter."
        ),
    )
    max_price: Optional[float] = Field(None, description="Max price in USD")
    brands: Optional[List[str]] = Field(None, description="List of brands (Zara, Bershka, Pull&Bear, Stradivarius ONLY)")
    text_query: Optional[str] = Field(
        None,
        description=(
            "Optional: ONE short keyword per call for product name/description ILIKE matching "
            "(e.g. 'flat', 'denim'). No full sentences, occasions (wedding), or verbs (find, show). "
            "If the user gave multiple keywords, use separate StructuredSearch calls — one keyword each — not one combined string."
        ),
    )
    gender: Optional[str] = Field(
        "woman",
        description=(
            "Must match the same catalog gender string you used in GetStoreOptions for this search "
            "(e.g. woman, man). Defaults to woman if unspecified."
        ),
    )

async def structured_search_logic(db: Session, **filters) -> List[Dict]:
    gender = filters.pop("gender", None) or "woman"
    text_query = filters.pop("text_query", None)
    size_raw = filters.pop("size", None)
    size_id = None
    if size_raw is not None and str(size_raw).strip():
        size_id = resolve_size_id_by_code(db, str(size_raw).strip())

    try:
        query = (
            db.query(Product)
            .options(joinedload(Product.brand))
            .join(MenuCategory)
            .filter(
                Product.is_active == True,
                MenuCategory.gender == gender,
            )
        )

        if filters.get("max_price"):
            query = query.filter(Product.price <= filters["max_price"] * USD_TO_LBP)

        if filters.get("category"):
            query = query.filter(func.lower(MenuCategory.name) == filters["category"].lower())

        if filters.get("subcategory"):
            query = query.join(Subcategory, Product.subcategory_id == Subcategory.id
            ).filter(func.lower(Subcategory.name) == filters["subcategory"].lower())

        if filters.get("color"):
            query = query.join(ProductColor).join(ColorFilter).filter(func.lower(ColorFilter.name) == filters["color"].lower())

        if size_id is not None:
            query = query.filter(
                Product.product_colors.any(
                    ProductColor.variants.any(
                        and_(
                            ProductVariant.size_id == size_id,
                            ProductVariant.availability == "in_stock",
                            ProductVariant.is_active == True,
                        )
                    )
                )
            )

        if filters.get("brands"):
            query = query.join(Brand).filter(Brand.name.in_(filters["brands"]))

        if text_query:
            pattern = f"%{text_query.strip()}%"
            query = query.filter(or_(Product.name.ilike(pattern), Product.description.ilike(pattern)))

        results = query.limit(100).all()

        return [{
            "id": p.id,
            "name": p.name,
            "price_usd": round(p.price / USD_TO_LBP, 2),
            "description": p.description,
            "brand": p.brand.name,
        } for p in results]

    except Exception as e:
        return []