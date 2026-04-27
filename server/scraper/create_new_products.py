import asyncio
from models.products.product import Product
from scraper.product_matching_service import match_categories, match_style
from scraper.update_existing_products import sync_colors_and_variants
from utils.hugging_face_utils import get_embedding_with_image_retry

async def process_new_product(db, product_data, brand_id, existing_products_map, db_size_master, db_variant_ids, db_image_ids, now, category_map, db_brand_colors):
    external_id = str(product_data["id"])
    variants_list = product_data.get("variants", [])
    scraper_gender = product_data.get("gender", "men").lower()
    if not variants_list:
        return

    all_representative_images = []
    for variant in variants_list:
        all_representative_images.extend(variant.get("images", []))

    descriptive_text = f"{product_data.get('name')} {product_data.get('description', '')}"
    product_embedding = await get_embedding_with_image_retry(all_representative_images, descriptive_text)

    menu_category_id, subcategory_id = (None, None)
    style_id = None
    if product_embedding:
        menu_category_id, subcategory_id = await match_categories(db, product_embedding, scraper_gender)
        style_id = await match_style(db, product_embedding)

    if external_id in existing_products_map:
        product_object = existing_products_map[external_id]
        product_object.embedding = product_embedding
        product_object.menu_category_id = menu_category_id
        product_object.subcategory_id = subcategory_id
        product_object.style_id = style_id
        product_object.price = product_data.get("price")
        if product_data.get("url"):
            product_object.url = product_data.get("url")
        product_object.is_active = True
        product_object.last_scraped_at = now
    else:
        product_object = Product(
            product_id=external_id,
            brand_id=brand_id,
            name=product_data.get("name"),
            description=product_data.get("description"),
            price=product_data.get("price"),
            url=product_data.get("url"),
            gender=scraper_gender,
            embedding=product_embedding,
            menu_category_id=menu_category_id,
            subcategory_id=subcategory_id,
            style_id=style_id,
            category_id=category_map.get(str(product_data.get("category_id"))),
            is_active=True,
            last_scraped_at=now,
            created_at=now
        )
        db.add(product_object)
        db.flush()
        existing_products_map[external_id] = product_object

    await sync_colors_and_variants(db, product_data, product_object, db_size_master, db_variant_ids, db_image_ids, now, db_brand_colors)