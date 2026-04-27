from scraper.fetch_url import fetch_json
from collections import deque
from scraper.constants.zara_constants import *

# extract categories from the Zara API 
async def get_categories_from_zara():
    try:
        print("Fetching Zara categories...")
        data = await fetch_json(CATEGORIES_URL, HEADERS)
        if not data:
            raise Exception("Failed to retrieve Zara categories from API")
        
        categories = extract_zara_categories(data.get("categories", []))
        print(f"Total categories extracted: {len(categories)}")
        return categories

    except Exception as e:
        print(f"Error during Zara category extraction: {e}")
        raise Exception(f"Zara category sync failed: {e}")


# extract all valid categories from the response data
def extract_zara_categories(categories):
    valid_categories = []
    seen_ids = set()
    queue = deque()

    # seed queue with top-level categories
    for cat in categories:
        queue.append({"data": cat, "parent_name": None})

    while queue:
        item = queue.popleft()
        node = item["data"]
        parent_name = item["parent_name"]

        section = node.get("sectionName")
        name = node.get("name")
        cat_id = node.get("id")
        subcats = node.get("subcategories", [])

        # skip invalid or missing IDs
        if not cat_id or not is_valid_category(section, name):
            continue

        # deduplicate by external_category_id
        if cat_id not in seen_ids:
            seen_ids.add(cat_id)
            valid_categories.append({
                "id": cat_id,
                "gender": section,
                "category_name": parent_name or name,
                "subcategory_name": name if parent_name else None
            })

        # current node becomes parent for its children
        next_parent = parent_name or name
        for sub in subcats:
            queue.append({"data": sub, "parent_name": next_parent})

    return valid_categories


# validate a category based on brand-specific section constraints
def is_valid_category(section, name):
    return bool(name) and section in MAIN_SECTIONS
