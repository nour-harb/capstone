from typing import Callable, Optional
from urllib.parse import urlencode

from scraper.fetch_url import fetch_batch_json
from scraper.constants.stradi_constants import STRADI_CONFIG
from scraper.constants.pb_constants import PB_CONFIG
from scraper.constants.bershka_constants import BERSHKA_CONFIG
from scraper.get_products.get_brand_product_ids import (
    fetch_stradi_products_for_categories,
    fetch_pb_products_for_categories,
    fetch_bershka_products_for_categories,
)
from scraper.get_products.format_price import format_price

# Bershka: name with spaces -> '-', then -c0p{id}.html on base URL
def build_bershka_product_url(product_data, base_url: str) -> Optional[str]:
    name = (product_data.get("name") or "").strip()
    pid = str(product_data.get("id") or "").strip()
    if not name or not pid:
        return None
    slug = "-".join(name.lower().split())
    filename = f"{slug}-c0p{pid}.html"
    base = (base_url or "").rstrip("/") + "/"
    return base + filename

# Stradivarius / P&B: API productUrl as-is (no .html appended) on base URL
def build_stradi_pb_product_url(product_data, base_url: str) -> Optional[str]:
    segment = (product_data.get("productUrl") or "").strip().lstrip("/")
    if not segment:
        return None
    base = (base_url or "").rstrip("/") + "/"
    return base + segment


async def get_product_details_from_stradi(category_ids):
    return await get_product_details(
        category_ids,
        STRADI_CONFIG,
        fetch_stradi_products_for_categories,
        lambda d: build_stradi_pb_product_url(d, STRADI_CONFIG["BASE_URL"]),
    )


async def get_product_details_from_pb(category_ids):
    return await get_product_details(
        category_ids,
        PB_CONFIG,
        fetch_pb_products_for_categories,
        lambda d: build_stradi_pb_product_url(d, PB_CONFIG["BASE_URL"]),
    )


async def get_product_details_from_bershka(category_ids):
    return await get_product_details(
        category_ids,
        BERSHKA_CONFIG,
        fetch_bershka_products_for_categories,
        lambda d: build_bershka_product_url(d, BERSHKA_CONFIG["BASE_URL"]),
    )


# main function to fetch full product details in batches
async def get_product_details(
    category_ids,
    brand_config,
    product_id_fetcher,
    build_product_url: Optional[Callable[[dict], Optional[str]]] = None,
):
    try:
        # fetch the list of product IDs associated with their categories
        product_ids_with_category = await product_id_fetcher(category_ids)
        
        if not product_ids_with_category:
            raise Exception(f"Batch fetch failed for {brand_config['BRAND_NAME']}")

        print(f"Fetching product details for {len(product_ids_with_category)} products...")

        # create a lookup map to link product IDs back to their category IDs later
        id_to_category_map = {}
        category_to_products = {}

        for p in product_ids_with_category:
            p_id = str(p.get("id"))
            c_id = p.get("category_id")
            if p_id and c_id:
                id_to_category_map[p_id] = c_id
                # group product IDs by category for batched API requests
                if c_id not in category_to_products:
                    category_to_products[c_id] = []
                category_to_products[c_id].append(p_id)

        # prepare the batched URLs for the product details API
        url_data = []
        batch_size = brand_config["BATCH_SIZE"]
        
        for category_id, product_ids in category_to_products.items():
            for i in range(0, len(product_ids), batch_size):
                batch_chunk = product_ids[i:i + batch_size]
                
                params = {
                    'categoryId': category_id,
                    'productIds': ",".join(batch_chunk),
                    'appId': '1', 'languageId': '-1', 'locale': 'en_US'
                }
                
                url = f"{brand_config['PRODUCT_DETAILS_URL']}?{urlencode(params)}"
                url_data.append(url)

        print(f"Executing {len(url_data)} batched detail requests...")
        batch_results = await fetch_batch_json(url_data, brand_config["HEADERS"])
        
        if batch_results is None:
            raise Exception(f"Failed to fetch product details for {brand_config['BRAND_NAME']}")

        all_fetched_products = []

        # process the batch responses
        for batch_data in batch_results:
            if batch_data is None:
                continue
                
            products_list = batch_data.get("products", [])
            for product_data in products_list:
                try:
                    p_id = str(product_data.get("id"))
                    category_id = id_to_category_map.get(p_id)

                    page_url = (
                        build_product_url(product_data)
                        if build_product_url is not None
                        else None
                    )
                    unified_product = unify_product_from_inditex(
                        product_data, category_id, url=page_url
                    )
                    if unified_product:
                        all_fetched_products.append(unified_product)
                except Exception:
                    continue

        # deduplication based on reference code
        final_products = []
        seen_refs = set()

        for p in all_fetched_products:
            ref = p.get("reference")
            if ref and ref.strip():
                if ref in seen_refs:
                    continue
                seen_refs.add(ref)
            final_products.append(p)

        print(f"After second de-duplication: final product count:{len(final_products)}")
        
        return final_products

    except Exception as e:
        print(f"Critical error fetching product details for {brand_config.get('BRAND_NAME')}: {e}")
        raise Exception(f"Product detail extraction halted: {e}")

# transform API response into a clean dictionary
def unify_product_from_inditex(data, category_id=None, url=None):
    bundle_summaries = data.get("bundleProductSummaries", [])
    product_name = data.get("name", "").strip()
    
    if not bundle_summaries or not product_name:
        return None
    
    raw_section = data.get("sectionNameEN", "").lower()
    if "women" in raw_section:
        normalized_gender = "woman"
    elif "men" in raw_section:
        normalized_gender = "man"
    else:
        normalized_gender = raw_section
    
    product_detail = bundle_summaries[0]
    detail_data = product_detail.get("detail", {})
    colors = detail_data.get("colors", [])
    xmedia_items = detail_data.get("xmedia", [])

    # extract base price from the first available size
    final_price = None
    for color in colors:
        for size in color.get("sizes", []):
            if size.get("price"):
                final_price = format_price(size.get("price"))
                break
        if final_price:
            break

    # initialize the unified product structure
    prod = {
        "id": str(data.get("id")),
        "reference": detail_data.get("displayReference"),
        "name": product_name,
        "gender": normalized_gender,
        "family": data.get("familyNameEN"),
        "subfamily": data.get("subfamilyNameEN"),
        "seo": data.get("productUrl", ""),
        "url": url,
        "description": detail_data.get("longDescription", ""),
        "price": final_price,
        "category_id": category_id,
        "variants": [],
    }

    # process each color variant
    for color in colors:
        color_id = str(color.get("id"))
        
        # collect all valid media items for this color
        raw_media_list = []
        for xm in xmedia_items:
            if str(xm.get("colorCode")) == color_id:
                for xset in xm.get("xmediaItems", []):
                    for media in xset.get("medias", []):
                        if media.get("format") != 4 and media.get("url"):
                            raw_media_list.append(media)
        
        raw_media_list.sort(key=lambda x: x.get("extraInfo", {}).get("originalName") != "s1")

        images = []
        for index, media in enumerate(raw_media_list):
            images.append({
                "imageId": media.get("idMedia"),
                "url": media.get("url"),
                "imageType": f"type_{media.get('clazz')}" if media.get('clazz') else "main",
                "order": index + 1,  
                "width": None, "height": None,
            })
        
        # fallback to the main color image if xmedia list is empty
        if not images:
            color_image = color.get("image", {})
            if color_image and color_image.get("url"):
                images.append({
                    "imageId": f"{color_id}_main",
                    "url": color_image["url"],
                    "imageType": "main",
                    "order": 1, 
                })

        # process sizes and handle display logic for multi-type sizes (e.g., Petite vs Regular)
        all_sizes = color.get("sizes", [])
        all_types = {s.get('sizeType', '').strip() for s in all_sizes if s.get('sizeType')}
        include_size_type = len(all_types) > 1 

        sizes_data = []
        for size in all_sizes:
            s_name = size.get('name', '').strip()
            if include_size_type:
                s_name = f"{s_name} {size.get('sizeType', '').title()}".strip()
            
            availability = "in_stock" if size.get("visibilityValue") == "SHOW" else "out_of_stock"
            
            sizes_data.append({
                "size_name": s_name,
                "availability": availability,
                "price": format_price(size.get("price")), 
            })

        # add the completed variant to the product
        prod["variants"].append({
            "color_id": color_id,
            "hex_code": None,
            "color_name": color.get("name"),
            "images": images,
            "sizes": sizes_data,
        })

    return prod