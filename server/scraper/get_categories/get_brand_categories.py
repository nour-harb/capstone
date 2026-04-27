from collections import deque
from scraper.fetch_url import fetch_json
from scraper.constants.stradi_constants import STRADI_CONFIG
from scraper.constants.pb_constants import PB_CONFIG


async def get_categories_from_pb():
    return await get_categories_from_stradi_pb(PB_CONFIG)


async def get_categories_from_stradi():
    return await get_categories_from_stradi_pb(STRADI_CONFIG)


# extract categories from the Stradivarius or Pull&Bear API using a queue
async def get_categories_from_stradi_pb(brand_config):
    try:
        print(f"Fetching {brand_config['BRAND_NAME']} categories...")

        data = await fetch_json(
            brand_config["CATEGORIES_URL"],
            brand_config["HEADERS"]
        )

        if not data:
            raise Exception(
                f"Failed to retrieve {brand_config['BRAND_NAME']} categories from API"
            )

        valid_categories = []
        seen_ids = set()
        queue = deque()

        for root_cat in data.get("categories", []):
            queue.append({
                "data": root_cat,
                "gender": None,
                "parent_name": None
            })

        while queue:
            item = queue.popleft()
            node = item["data"]
            gender = item["gender"]
            parent_name = item["parent_name"]

            name = node.get("name")
            cat_id = node.get("id")
            subcats = node.get("subcategories", [])

            # detect gender nodes 
            if name and name.upper() in {"WOMAN", "MAN"}:
                gender = name.capitalize()
                parent_name = None

            # register category once gender context exists
            if gender and name != gender and cat_id not in seen_ids:
                seen_ids.add(cat_id)
                valid_categories.append({
                    "id": cat_id,
                    "gender": gender,
                    "category_name": parent_name or name,
                    "subcategory_name": name if parent_name else None
                })

            # determine parent for children
            next_parent = parent_name
            if gender and name != gender and parent_name is None:
                next_parent = name

            for sub in subcats:
                queue.append({
                    "data": sub,
                    "gender": gender,
                    "parent_name": next_parent
                })

        print(f"Total categories extracted: {len(valid_categories)}")
        return valid_categories

    except Exception as e:
        raise Exception(
            f"Error extracting {brand_config['BRAND_NAME']} categories: {e}"
        )
