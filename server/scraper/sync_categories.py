from utils.date_time_now import now_utc
from sqlalchemy.orm import Session
from models.products.category import Category

# syncs the fetched categories with the database
# updates existing ones, adds new ones, and deactivates those no longer present in the latest scrape
async def insert_categories_to_db(db: Session, categories, brand_id, brand_name):
    try:
        if not brand_id or not categories: 
            return

        now = now_utc()
        
        # loading all existing categories from db into a dictionary for fast lookups 
        existing_categories = db.query(Category).filter(Category.brand_id == brand_id).all()
        existing_map = {str(c.external_category_id): c for c in existing_categories}

        
        matched_ids = set()
        for cat in categories:
            external_cat_id = str(cat["id"])
            matched_ids.add(external_cat_id)
            
            existing = existing_map.get(external_cat_id)

            if existing:
                # update existing category details and refresh timestamps
                existing.gender = cat["gender"]
                existing.category_name = cat["category_name"]
                existing.subcategory_name = cat.get("subcategory_name")
                existing.is_active = True
                existing.last_scraped_at = now
                existing.updated_at = now
            else:
                # add a new category
                new_cat = Category(
                    external_category_id=external_cat_id, 
                    brand_id=brand_id,
                    gender=cat["gender"], 
                    category_name=cat["category_name"],
                    subcategory_name=cat.get("subcategory_name"),
                    is_active=True, 
                    last_scraped_at=now,
                    created_at=now
                )
                db.add(new_cat)

        # deactivate ctageoriess in the db not in the current scrape
        db.query(Category).filter(
            Category.brand_id == brand_id,
            Category.external_category_id.not_in(matched_ids)
        ).update(
            {"is_active": False, "last_scraped_at": now}, 
            synchronize_session=False
        )

        db.flush()
        
        print(f"Categories synced for {brand_name}: {len(matched_ids)} active.")

    except Exception as e:
        print(f"Failed to insert categories for {brand_name}: {str(e)}")
        raise