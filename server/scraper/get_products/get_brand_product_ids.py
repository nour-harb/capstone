from scraper.fetch_url import fetch_batch_json
from urllib.parse import urlencode
from scraper.constants.stradi_constants import STRADI_CONFIG
from scraper.constants.pb_constants import PB_CONFIG
from scraper.constants.bershka_constants import BERSHKA_CONFIG

async def fetch_pb_products_for_categories(category_ids):
    return await fetch_products_for_categories(PB_CONFIG, category_ids)

async def fetch_stradi_products_for_categories(category_ids):
    return await fetch_products_for_categories(STRADI_CONFIG, category_ids)

async def fetch_bershka_products_for_categories(category_ids):
    return await fetch_products_for_categories(BERSHKA_CONFIG, category_ids)

# main function that gets all product IDs for category_ids concurrently
async def fetch_products_for_categories(brand_config, category_ids):
    try:
        urls = []
        # convert IDs to strings and build the target URLs
        ordered_category_ids = [str(cid) for cid in category_ids]
        
        for category_id in ordered_category_ids:
            # inject the category ID into the base URL template
            base_url = brand_config["PRODUCTS_URL"].format(category_id=category_id)
            query_string = urlencode(brand_config["PARAMS"])
            url = f"{base_url}?{query_string}"
            urls.append(url)
        
        print(f"Feching product IDs for: {brand_config['BRAND_NAME']} ({len(urls)} categories)")
        
        # oerform parallel requests using the shared client
        batch_results = await fetch_batch_json(urls, brand_config["HEADERS"])
        
        # stop everything if the fetch returned no data at all
        if batch_results is None:
            raise Exception(f"Batch fetch failed for {brand_config['BRAND_NAME']}")

        all_product_ids = []
        failed_count = 0
        
        # loop through results and pair them back with their category IDs
        for i in range(len(batch_results)):
            category_data = batch_results[i]
            category_id = ordered_category_ids[i]
            
            if category_data is None:
                failed_count += 1
                continue
                
            # extract IDs and add them to the main list
            product_list = extract_product_ids_from_category(category_data, category_id)
            all_product_ids.extend(product_list)

        print(f"Fetched {len(all_product_ids)} IDs.")

        if not all_product_ids:
            return []

        # remove duplicate product IDs
        unique_products_dict = {}
        for item in all_product_ids:
            pid = item["id"]
            unique_products_dict[pid] = item
        
        final_list = list(unique_products_dict.values())
        print(f"After de-duplication: final product count: {len(final_list)}")
        
        return final_list

    except Exception as e:
        print(f"Sync error for {brand_config.get('BRAND_NAME')}: {e}")
        raise Exception(f"Stopping execution due to brand failure: {brand_config.get('BRAND_NAME')}")

# extract IDs from the JSON category response
def extract_product_ids_from_category(data, category_id):
    if not data:
        return []
    
    raw_ids = data.get('productIds', [])
    
    formatted_products = []
    for pid in raw_ids:
        formatted_products.append({
            "id": str(pid),
            "category_id": category_id
        })
        
    return formatted_products