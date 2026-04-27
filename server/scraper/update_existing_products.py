import asyncio
from models.products.product_color import ProductColor
from models.products.image import Image
from models.products.product_variant import ProductVariant
from models.products.size_master import SizeMaster
from models.products.brand_color_map import BrandColorMap
from scraper.product_matching_service import match_color_filter
from utils.hugging_face_utils import get_embedding_with_image_retry

async def sync_colors_and_variants(db, product_data, product_object, db_size_master, db_variant_ids, db_image_ids, now, db_brand_colors):
    variants = product_data.get("variants", [])
    color_generation_results = {}

    colors_needing_ai = []
    ai_tasks = []
    for variant in variants:
        external_color_id = str(variant.get("color_id"))
        existing_color = db.query(ProductColor).filter_by(
            product_id=product_object.id,
            external_color_id=external_color_id
        ).first()
        if not existing_color or existing_color.embedding is None:
            colors_needing_ai.append(variant)
            descriptive_text = f"{variant.get('color_name')} {variant.get('name')} {variant.get('description', '')}"
            ai_tasks.append(get_embedding_with_image_retry(variant.get("images", []), descriptive_text))

    if ai_tasks:
        embeddings = await asyncio.gather(*ai_tasks)
        for variant, embedding in zip(colors_needing_ai, embeddings):
            color_name = variant.get("color_name")
            filter_id = db_brand_colors.get(color_name)
            if not filter_id and embedding:
                filter_id = await match_color_filter(db, embedding)
                if filter_id:
                    db.add(BrandColorMap(brand_id=product_object.brand_id, color_name=color_name, color_filter_id=filter_id))
                    db_brand_colors[color_name] = filter_id
            color_generation_results[str(variant.get("color_id"))] = {"embedding": embedding, "filter_id": filter_id}

    for variant in variants:
        external_color_id = str(variant.get("color_id"))
        color_object = db.query(ProductColor).filter_by(
            product_id=product_object.id,
            external_color_id=external_color_id
        ).first()
        if not color_object:
            generated_data = color_generation_results.get(external_color_id, {})
            color_object = ProductColor(
                product_id=product_object.id,
                external_color_id=external_color_id,
                name=variant.get("color_name"),
                hexcode=variant.get("hex_code"),
                embedding=generated_data.get("embedding"),
                color_filter_id=generated_data.get("filter_id"),
                is_active=True,
                last_scraped_at=now
            )
            db.add(color_object)
            db.flush()
        else:
            if external_color_id in color_generation_results:
                color_object.embedding = color_generation_results[external_color_id].get("embedding")
                color_object.color_filter_id = color_generation_results[external_color_id].get("filter_id")
            color_object.is_active = True
            color_object.last_scraped_at = now

        # Images
        for image_data in variant.get("images", []):
            image_external_id = image_data.get("imageId")
            if image_external_id not in db_image_ids:
                url = image_data.get("url")
                if url and url.startswith("//"):
                    url = f"https:{url}"
                db.add(Image(
                    image_id=image_external_id,
                    product_id=product_object.id,
                    color_id=color_object.id,
                    url=url,
                    order=image_data.get("order"),
                    is_active=True,
                    last_scraped_at=now
                ))
                db_image_ids.add(image_external_id)

        # Size variants
        for size_data in variant.get("sizes", []):
            label = size_data.get("size_name")
            size_record = db_size_master.get(label)
            if not size_record:
                size_record = SizeMaster(code=label)
                db.add(size_record)
                db.flush()
                db_size_master[label] = size_record
            variant_key = (color_object.id, size_record.id)
            if variant_key not in db_variant_ids:
                variant_object = ProductVariant(
                    product_color_id=color_object.id,
                    size_id=size_record.id,
                    is_active=True,
                    last_scraped_at=now
                )
                db.add(variant_object)
                db_variant_ids.add(variant_key)
            else:
                variant_object = db.query(ProductVariant).filter_by(
                    product_color_id=color_object.id,
                    size_id=size_record.id
                ).first()
            if variant_object:
                variant_object.price = size_data.get("price")
                variant_object.availability = size_data.get("availability")
                variant_object.is_active = True
                variant_object.last_scraped_at = now