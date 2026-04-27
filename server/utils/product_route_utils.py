from typing import List, Optional
from sqlalchemy import and_, asc, desc, func, or_, cast, String
from sqlalchemy.orm import Session
from models.products.menu_category import MenuCategory
from models.products.subcategory import Subcategory
from models.products.color_filters import ColorFilter
from models.products.brand import Brand
from models.products.product import Product
from models.products.product_color import ProductColor
from models.products.product_variant import ProductVariant
from models.products.size_master import SizeMaster
from pydantic_schemas.products.product_response import ProductResponse

# return all available filters for products
def get_available_filters(db: Session, base_query, menu_category_id: int):
    # get IDs of products in the current query to filter related data
    current_product_ids = [p.id for p in base_query.with_entities(Product.id).all()]

    # get brands of those products only
    active_brand_ids = db.query(Product.brand_id)\
        .filter(Product.id.in_(current_product_ids))\
        .distinct().all()
    brand_id_list = [id[0] for id in active_brand_ids]
    brands = db.query(Brand).filter(Brand.id.in_(brand_id_list)).all()

    # join product_variants to product_colors, then filter by our product list
    active_size_ids = db.query(ProductVariant.size_id)\
        .join(ProductColor)\
        .filter(ProductColor.product_id.in_(current_product_ids))\
        .filter(ProductVariant.is_active == True)\
        .distinct().all()
    size_id_list = [id[0] for id in active_size_ids]
    sizes = db.query(SizeMaster).filter(SizeMaster.id.in_(size_id_list)).all()

    # get color filters of those products only
    active_color_ids = db.query(ProductColor.color_filter_id)\
        .filter(ProductColor.product_id.in_(current_product_ids))\
        .filter(ProductColor.is_active == True)\
        .distinct().all()
    color_id_list = [id[0] for id in active_color_ids]
    color_filters = db.query(ColorFilter).filter(ColorFilter.id.in_(color_id_list)).all()

    # get existing subcategories
    subcategories_data = []
    if menu_category_id > 0:
        subcategories = db.query(Subcategory).filter(
            Subcategory.menu_category_id == menu_category_id,
            Subcategory.is_active == True
        ).order_by(Subcategory.name.asc()).all()
        subcategories_data = [{"id": s.id, "name": s.name} for s in subcategories]

    return {
        "subcategories": subcategories_data,
        "brands": [{"id": b.id, "name": b.name} for b in brands],
        "sizes": [{"id": s.id, "name": s.code} for s in sizes],
        "colors": [{"id": cf.id, "name": cf.name, "hex": cf.hexcode} for cf in color_filters]
    }

# apply filters
def get_products_for_category(base_query, params):
    if hasattr(params, 'subcategory_id') and params.subcategory_id:
        base_query = base_query.filter(Product.subcategory_id == params.subcategory_id)
        
    if params.brand_ids:
        base_query = base_query.filter(Product.brand_id.in_(params.brand_ids))

    if params.color_ids:
        base_query = base_query.filter(Product.product_colors.any(
            and_(ProductColor.color_filter_id.in_(params.color_ids), ProductColor.is_active == True)
        ))
        
    if params.size_ids:
        base_query = base_query.filter(Product.product_colors.any(
            ProductColor.variants.any(
                and_(ProductVariant.size_id.in_(params.size_ids), ProductVariant.is_active == True, ProductVariant.availability == 'in_stock')
            )
        ))

    if params.sort_by == "price_asc": 
        base_query = base_query.order_by(asc(Product.price))
    elif params.sort_by == "price_desc": 
        base_query = base_query.order_by(desc(Product.price))
    else: 
        base_query = base_query.order_by(desc(Product.created_at))

    offset = (params.page - 1) * params.page_size
    products = base_query.offset(offset).limit(params.page_size).all()

    return format_products(products, params.color_ids)

# format products for frontend by selecting main image and color and color count
def format_products(products, selected_filter_ids):
    result = []
    for p in products:
        active_colors = [c for c in p.product_colors if c.is_active]
        main_color_obj = next((c for c in active_colors if c.color_filter_id in selected_filter_ids), None) if selected_filter_ids else None
        if not main_color_obj and active_colors: 
            main_color_obj = active_colors[0]

        img = next((i for i in p.images if i.color_id == main_color_obj.id), None) if main_color_obj else None
        if not img and p.images: 
            img = p.images[0]

        result.append(ProductResponse(
            id=p.id, 
            name=p.name, 
            price=p.price,
            brand=p.brand.name if p.brand else None,
            main_image_url=img.url if img else None,
            main_color=main_color_obj.name if main_color_obj else None,
            other_colors_count=max(len(active_colors) - 1, 0),
            menu_category_id=p.menu_category_id,
            subcategory_id=p.subcategory_id,
            gender=p.gender
        ))
    return result

# extract and return metadata from search query using keyword matching and embedding similarity
async def parse_search_query(db: Session, query_text: str, gender: str, menu_category_id: Optional[int] = None):
    
    words = query_text.lower().split()
    extracted = {
        "brand_id": None,
        "color_filter_id": None,
        "menu_category_id": menu_category_id,
        "subcategory_id": None
    }

    for word in words:
        if not extracted["brand_id"]:
            brand = db.query(Brand).filter(Brand.name.ilike(word)).first()
            if brand:
                extracted["brand_id"] = brand.id

        if not extracted["menu_category_id"]:
            json_pattern = f'"{word}"' 
            
            m_cat = db.query(MenuCategory).filter(
                MenuCategory.gender == gender,
                or_(
                    MenuCategory.name.ilike(word),
                    cast(MenuCategory.keywords, String).ilike(f'%{json_pattern}%')
                )
            ).first()
            if m_cat:
                extracted["menu_category_id"] = m_cat.id

        if not extracted["color_filter_id"]:
            json_pattern = f'"{word}"'
            color = db.query(ColorFilter).filter(
                or_(
                    ColorFilter.name.ilike(word),
                    cast(ColorFilter.keywords, String).ilike(f'%{json_pattern}%')
                )
            ).first()
            if color:
                extracted["color_filter_id"] = color.id

    if extracted["menu_category_id"] and not extracted["subcategory_id"]:
        for word in words:
            json_pattern = f'"{word}"'            
            sub = db.query(Subcategory).filter(
            Subcategory.menu_category_id == extracted["menu_category_id"],
                or_(
                    Subcategory.name.ilike(word),
                    cast(Subcategory.keywords, String).ilike(f'%{word}%')
                )
            ).first()
            if sub:
                extracted["subcategory_id"] = sub.id
                break

    return extracted

async def execute_search(
    db: Session, query_text: str, gender: str, metadata: dict,
    color_ids: List[int], size_ids: List[int], brand_ids: List[int],
    page: int, page_size: int,sort_by: str
):
    words = query_text.lower().split()
    
    base_query = db.query(Product).filter(Product.is_active == True, Product.gender == gender)

    has_metadata = any([metadata["brand_id"], metadata["menu_category_id"], metadata["color_filter_id"]])

    if metadata["brand_id"]: 
        base_query = base_query.filter(Product.brand_id == metadata["brand_id"])
    if metadata["menu_category_id"]: 
        base_query = base_query.filter(Product.menu_category_id == metadata["menu_category_id"])
    if metadata["subcategory_id"]: 
        base_query = base_query.filter(Product.subcategory_id == metadata["subcategory_id"])
    if metadata["color_filter_id"]:
        base_query = base_query.filter(Product.product_colors.any(
            and_(ProductColor.color_filter_id == metadata["color_filter_id"], ProductColor.is_active == True)
        ))

    if not has_metadata:        
        word_conditions = []
        for word in words:
            search_target = f" {word} "
            condition = or_(
                func.concat(" ", func.lower(Product.name), " ").ilike(f"%{search_target}%"),
                func.concat(" ", func.lower(Product.description), " ").ilike(f"%{search_target}%")
            )
            word_conditions.append(condition)
        
        base_query = base_query.filter(or_(*word_conditions))

    available_filters = get_available_filters(db, base_query, metadata["menu_category_id"] or 0)
    grid_query = base_query

    if brand_ids: grid_query = grid_query.filter(Product.brand_id.in_(brand_ids))
    if color_ids: 
        grid_query = grid_query.filter(Product.product_colors.any(
            and_(ProductColor.color_filter_id.in_(color_ids), ProductColor.is_active == True)
        ))
    if size_ids:
        grid_query = grid_query.filter(Product.product_colors.any(
            ProductColor.variants.any(
                and_(ProductVariant.size_id.in_(size_ids), ProductVariant.is_active == True)
            )
        ))

    full_phrase_target = f" {query_text.lower()} "
    grid_query = grid_query.order_by(
        desc(func.concat(" ", func.lower(Product.name), " ").ilike(f"%{full_phrase_target}%"))    )

    offset = (page - 1) * page_size
    products = grid_query.offset(offset).limit(page_size).all()

    return products, available_filters