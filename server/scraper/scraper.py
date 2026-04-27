from sqlalchemy.orm import Session

from scraper.get_products.get_brand_products import get_product_details_from_stradi
from scraper.get_categories.get_brand_categories import get_categories_from_stradi

from scraper.sync_categories import insert_categories_to_db
from scraper.sync_products import insert_products_to_db
from utils.favorite_drop_utils import refresh_favorite_drop_flags

from scraper.get_products.get_zara_products import get_product_details_from_zara
from scraper.get_categories.get_zara_categories import get_categories_from_zara

from scraper.get_categories.get_bershka_categories import get_categories_from_bershka
from scraper.get_products.get_brand_products import get_product_details_from_bershka

from scraper.get_categories.get_brand_categories import get_categories_from_pb
from scraper.get_products.get_brand_products import get_product_details_from_pb
from models.products.brand import Brand
from models.products.category import Category

# main function to sync categories and products for all defined brands
async def sync_all_brands(db: Session):
    print("Starting sync...")
    
    # list of brands and their associated scraping functions
    brands = [
        ("Zara", get_categories_from_zara, get_product_details_from_zara),
        ("Bershka", get_categories_from_bershka, get_product_details_from_bershka),
        ("PULL&BEAR", get_categories_from_pb, get_product_details_from_pb),
        ("Stradivarius", get_categories_from_stradi, get_product_details_from_stradi)
    ]
    
    for brand_name, category_func, product_func in brands:
        try:
            print(f"\nSyncing {brand_name}...")
            
            # get brand id
            brand = db.query(Brand).filter(Brand.name == brand_name).first()
            if not brand or brand.is_active == False:
                print(f"Brand {brand_name} not found in database. Skipping...")
                continue 
                    
            # sync categories
            category_map = await sync_brand_categories(db, brand, category_func)
            if not category_map:
                print(f"No categories found for {brand_name}. Skipping products...")
                continue
                
            # sync products using the fetched categories
            product_count = await sync_brand_products(db, brand, product_func, category_map)
            
            # commit the changes for this brand if everything succeeded
            db.commit() 
            print(f"Success: {brand_name} synced with {product_count} products.")

        except Exception as e:
            # if any part of the brand sync fails, rollback db changes for this brand only
            db.rollback()
            print(f"ERROR syncing {brand_name}: {str(e)}")
            print(f"Continuing with next brand...")
            continue 

    try:
        refresh_favorite_drop_flags(db)
    except Exception as e:
        print(f"Warning: favorite drop refresh failed: {e}")

    print("\nFinished processing all brands.")

# fetches categories from the brand's API and updates the database
async def sync_brand_categories(db: Session, brand, category_func):
    # fetch fresh categories
    categories = await category_func()
    
    if categories:
        await insert_categories_to_db(db, categories, brand.id, brand.name)
    
    db_categories = db.query(Category).filter(
        Category.brand_id == brand.id, 
        Category.is_active == True
    ).all()
    
    return {str(cat.external_category_id): cat.id for cat in db_categories}

async def sync_brand_products(db: Session, brand, product_func, category_map):
    if not category_map:
        return 0
    
    # get product details from the brand's specific fetcher
    products = await product_func(list(category_map.keys()))
    
    if products:
        # upsert the products in the database
        await insert_products_to_db(db, products, brand.id, brand.name, category_map)
        return len(products)
    
    return 0