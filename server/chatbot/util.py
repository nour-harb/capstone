from typing import Any, Dict, List
from requests import Session
from sqlalchemy import and_
from sqlalchemy.orm import joinedload
from models.products.brand import Brand
from models.products.color_filters import ColorFilter
from models.products.menu_category import MenuCategory
from models.products.product import Product
from models.products.product_color import ProductColor
from models.products.product_variant import ProductVariant
from models.products.size_master import SizeMaster


def get_clean_text(content):
    if not content:
        return ""
    if hasattr(content, "content"):
        content = content.content
    if isinstance(content, str):
        return content.strip()

    if isinstance(content, list):
        parts = []
        for block in content:
            if isinstance(block, dict):
                if block.get("type") == "text":
                    parts.append(str(block.get("text", "")))
                else:
                    parts.append(
                        str(
                            block.get("text", "")
                            or block.get("thinking", "")
                            or block.get("reasoning", "")
                        )
                    )
            elif hasattr(block, "text"):
                parts.append(str(block.text))
            else:
                parts.append(str(block))
        return "".join(parts).strip()

    if isinstance(content, dict):
        return str(content.get("text", "") or content.get("output", "")).strip()

    return str(content).strip()


async def fetch_predefined_options(db: Session, gender: str) -> Dict[str, Any]:
    if gender is None:
        return {
            "categories": [],
            "categories_map": {},
            "subcategories": [],
            "brands": [b.name for b in db.query(Brand).all()],
            "colors": [c.name for c in db.query(ColorFilter).all()],
            "sizes": [],
        }
    categories = (
        db.query(MenuCategory)
        .options(joinedload(MenuCategory.subcategories))
        .filter(MenuCategory.gender == gender, MenuCategory.is_active == True)
        .order_by(MenuCategory.name.asc())
        .all()
    )
    categories_map: Dict[str, List[str]] = {}
    for c in categories:
        names = sorted(
            s.name
            for s in (c.subcategories or [])
            if getattr(s, "is_active", True)
        )
        categories_map[c.name] = names

    subcategories_flat = sorted({n for subs in categories_map.values() for n in subs})
    brands = db.query(Brand).all()
    colors = db.query(ColorFilter).all()
    size_id_rows = (
        db.query(ProductVariant.size_id)
        .join(ProductColor, ProductColor.id == ProductVariant.product_color_id)
        .join(Product, Product.id == ProductColor.product_id)
        .join(MenuCategory, Product.menu_category_id == MenuCategory.id)
        .filter(
            and_(
                MenuCategory.gender == gender,
                Product.is_active == True,
                ProductVariant.is_active == True,
                ProductVariant.size_id.isnot(None),
            )
        )
        .distinct()
        .all()
    )
    size_ids = [row[0] for row in size_id_rows if row[0] is not None]
    if size_ids:
        size_rows = (
            db.query(SizeMaster)
            .filter(SizeMaster.id.in_(size_ids))
            .order_by(SizeMaster.code.asc())
            .all()
        )
        sizes = [s.code for s in size_rows]
    else:
        sizes = []
    return {
        "categories": [c.name for c in categories],
        "categories_map": categories_map,
        "subcategories": subcategories_flat,
        "brands": [b.name for b in brands],
        "colors": [c.name for c in colors],
        "sizes": sizes,
    }

# Cache dropdown options per gender to avoid extra DB queries every request.
PREDEFINED_OPTIONS_CACHE: Dict[str, Dict[str, Any]] = {}


async def get_predefined_options_cached(db: Session, gender: str) -> Dict[str, Any]:
    if gender is None:
        return await fetch_predefined_options(db, gender)
    cached = PREDEFINED_OPTIONS_CACHE.get(gender)
    if cached is not None and "categories_map" in cached:
        return cached
    options = await fetch_predefined_options(db, gender)
    PREDEFINED_OPTIONS_CACHE[gender] = options
    return options

def check_if_timeout(response: Any) -> bool:
    patterns = [
        "agent stopped due to max iterations",
        "iteration limit",
        "time limit",
        "max iterations",
    ]
    s = response if isinstance(response, str) else str(response)
    lc = s.lower()
    if any(p in lc for p in patterns):
        print("DEBUGGG check_if_timeout: True")
        return True
    return False

