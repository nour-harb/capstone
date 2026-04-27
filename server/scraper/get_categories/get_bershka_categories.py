import re
from scraper.fetch_url import fetch_json
from scraper.constants.bershka_constants import *

# determine the category gender 
def get_gender_from_category(category_name):
    category_lower = category_name.lower()
    if "women" in category_lower or "woman" in category_lower:
        return "woman"
    elif "men" in category_lower or "man" in category_lower:
        return "man"
    else:
        # default to woman if gender is not explicitly mentioned in the name
        return "woman"

# extract categories from the Bershka API using regular expressions
async def get_categories_from_bershka():    
    try:
        print("Fetching Bershka categories...")
        # fetch the raw JSON data 
        data = await fetch_json(BERSHKA_CATEGORIES_URL, headers=HEADERS)
        if not data:
            print(f"Error: No data returned for Bershka category request")
            raise Exception(f"Failed to retrieve Bershka categories from API")
        
        categories = []
        seen_ids = set()
        
        # bershka categories are typically nested within the 'spots' key
        if isinstance(data, dict) and 'spots' in data:
            spots = data['spots']
            
            for item in spots:
                if 'value' in item:
                    # the value field often contains multi-line string configuration data
                    lines = item['value'].split('\n')
                    
                    for line in lines:
                        # locate lines containing both the category ID and the H1 display name
                        if 'ItxCategoryPage.' in line and '.h1=' in line:
                            # extract the ID and name using regular expression groups
                            match = re.search(r'ItxCategoryPage\.(\d+)\.h1=(.+)', line)
                            if match:
                                category_id = match.group(1)
                                category_name = match.group(2).strip()
                                
                                # prevent duplicate processing of the same category ID
                                if category_id not in seen_ids and category_name:
                                    seen_ids.add(category_id)
                                    
                                    gender = get_gender_from_category(category_name)
                                    
                                    categories.append({
                                        "id": int(category_id),
                                        "gender": gender,
                                        "category_name": category_name,
                                        "subcategory_name": None
                                    })
        
        print(f"Total categories extracted: {len(categories)}")
        return categories
        
    except Exception as e:
        print(f"Error: Error occurred during Bershka category extraction: {e}")
        raise Exception(f"Error extracting Bershka categories: {e}")