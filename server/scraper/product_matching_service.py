from sqlalchemy.orm import Session
from models.products.subcategory import Subcategory
from models.products.menu_category import MenuCategory
from models.products.style import Style
from models.products.color_filters import ColorFilter

async def match_categories(db: Session, product_embedding, scraper_gender: str):
    if not product_embedding:
        return None, None
    SUBCATEGORY_MATCH_THRESHOLD = 0.7
    scraper_gender = scraper_gender.lower().strip()
    best_matching_menu = db.query(MenuCategory).filter(MenuCategory.gender == scraper_gender).order_by(
        MenuCategory.embedding.cosine_distance(product_embedding)
    ).first()
    if not best_matching_menu:
        return None, None
    subcategory_match = db.query(
        Subcategory,
        Subcategory.embedding.cosine_distance(product_embedding).label("distance")
    ).filter(Subcategory.menu_category_id == best_matching_menu.id).order_by("distance").first()
    matched_subcategory_id = None
    if subcategory_match:
        subcategory_object, match_distance = subcategory_match
        if match_distance < SUBCATEGORY_MATCH_THRESHOLD:
            matched_subcategory_id = subcategory_object.id
    return best_matching_menu.id, matched_subcategory_id

async def match_style(db: Session, product_embedding):
    if not product_embedding:
        return None
    best_style_match = db.query(Style).order_by(
        Style.embedding.cosine_distance(product_embedding)
    ).first()
    return best_style_match.id if best_style_match else None

async def match_color_filter(db: Session, color_embedding):
    if not color_embedding:
        return None
    best_filter_match = db.query(ColorFilter).order_by(
        ColorFilter.embedding.cosine_distance(color_embedding)
    ).first()
    return best_filter_match.id if best_filter_match else None