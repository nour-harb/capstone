import asyncio
from sqlalchemy.orm import Session
from sqlalchemy import and_
from models.products.product import Product
from models.products.image import Image
from models.products.product_variant import ProductVariant
from models.products.size_master import SizeMaster
from models.products.brand_color_map import BrandColorMap
from models.products.product_color import ProductColor
from scraper.create_new_products import process_new_product
from scraper.update_existing_products import sync_colors_and_variants
from utils.date_time_now import now_utc

async def insert_products_to_db(db: Session, products_data, brand_id, brand_name, category_map):
    try:
        if not brand_id:
            print(f"Brand ID not provided for {brand_name}")
            return
        now = now_utc()

        all_external_product_ids = [str(product["id"]) for product in products_data]
        scraped_product_ids = set(all_external_product_ids)

        existing_products_map = {
            product.product_id: product
            for product in db.query(Product).filter(
                Product.brand_id == brand_id,
                Product.product_id.in_(all_external_product_ids)
            ).all()
        }

        db_product_ids = [product.id for product in existing_products_map.values()]

        db_image_ids = set()
        db_variant_ids = set()

        if db_product_ids:
            image_records = db.query(Image.image_id).filter(Image.product_id.in_(db_product_ids)).all()
            db_image_ids = {img.image_id for img in image_records}
            variant_records = db.query(
                ProductVariant.product_color_id,
                ProductVariant.size_id
            ).join(ProductColor).filter(
                ProductColor.product_id.in_(db_product_ids)
            ).all()
            db_variant_ids = {(var.product_color_id, var.size_id) for var in variant_records}

        db_size_master = {size.code: size for size in db.query(SizeMaster).all()}
        db_brand_colors = {mapping.color_name: mapping.color_filter_id for mapping in db.query(BrandColorMap).filter_by(brand_id=brand_id).all()}

        new_products = []
        existing_products = []
        for product_data in products_data:
            external_id = str(product_data["id"])
            if external_id in existing_products_map:
                if existing_products_map[external_id].embedding is None:
                    new_products.append(product_data)
                else:
                    existing_products.append(product_data)
            else:
                new_products.append(product_data)

        print(f"{brand_name}: {len(new_products)} new, {len(existing_products)} existing.")

        for index, product_data in enumerate(existing_products):
            product_object = existing_products_map[str(product_data["id"])]
            product_object.price = product_data.get("price")
            if product_data.get("url"):
                product_object.url = product_data.get("url")
            product_object.is_active = True
            product_object.last_scraped_at = now
            internal_category_id = category_map.get(str(product_data.get("category_id")))
            product_object.category_id = internal_category_id
            await sync_colors_and_variants(db, product_data, product_object, db_size_master, db_variant_ids, db_image_ids, now, db_brand_colors)
            if (index + 1) % 100 == 0:
                print(f"[{brand_name}] Updated {index + 1}/{len(existing_products)} existing...")

        BATCH_SIZE = 10
        for i in range(0, len(new_products), BATCH_SIZE):
            current_batch = new_products[i: i + BATCH_SIZE]
            processing_tasks = [
                process_new_product(
                    db, product_data, brand_id, existing_products_map, db_size_master,
                    db_variant_ids, db_image_ids, now, category_map, db_brand_colors
                )
                for product_data in current_batch
            ]
            await asyncio.gather(*processing_tasks)
            processed_so_far = len(existing_products) + i + len(current_batch)
            if (i + len(current_batch)) % 100 == 0 or (i + len(current_batch)) == len(new_products):
                print(f"[{brand_name}] {processed_so_far}/{len(products_data)} total items synced")

        db.query(Product).filter(
            and_(Product.brand_id == brand_id, ~Product.product_id.in_(scraped_product_ids))
        ).update({"is_active": False, "updated_at": now}, synchronize_session=False)
        db.flush()
    except Exception as error:
        print(f"Sync error for {brand_name}: {error}")
        raise