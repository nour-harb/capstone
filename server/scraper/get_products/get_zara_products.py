import re

from scraper.fetch_url import fetch_batch_json
from scraper.constants.zara_constants import *
from scraper.get_products.format_price import format_price


def build_zara_product_url(name, detail_data):
    """Full product page URL: slug from name + first 8 digits of reference + .html (inlined logic)."""
    if not name or not detail_data:
        return None
    slug = "-".join(str(name).strip().lower().split())
    ref_raw = detail_data.get("reference")
    if ref_raw is None or ref_raw == "":
        ref_raw = detail_data.get("displayReference") or ""
    digits = re.sub(r"\D", "", str(ref_raw))[:8]
    if len(digits) < 8:
        return None
    filename = f"{slug}-p{digits}.html"
    base = (ZARA_BASE_URL or "").rstrip("/") + "/"
    return base + filename

# main function to orchestrate Zara product extraction
async def get_product_details_from_zara(category_ids):
    try:
        urls = []
        ordered_category_ids = [str(cid) for cid in category_ids]
        
        for category_id in ordered_category_ids:
            url = PRODUCT_GROUPS_URL.format(category_id=category_id)
            urls.append(url)
        
        print(f"Feching product IDs for: Zara ({len(urls)} categories)")
        
        # parallel fetch of product groups
        batch_results = await fetch_batch_json(urls, HEADERS)
        
        if batch_results is None:
            raise Exception(f"Batch fetch failed for Zara")

        all_initial_data = []
        # process results and link them to their category_id
        for i, category_data in enumerate(batch_results):
            if not category_data:
                continue
            
            category_id = ordered_category_ids[i]
            for group in category_data.get("productGroups", []):
                # unify structure for initial deduplication
                all_initial_data.extend(unify_product_from_product_groups(group, category_id))

        print(f"Fetched {len(all_initial_data)} IDs.")

        # deduplicate based on ID before fetching heavy details
        seen_styles = set()
        unique_styles_to_fetch = []
        for p in all_initial_data:
            ref_id = p["id"]
            if ref_id and ref_id not in seen_styles:
                seen_styles.add(ref_id)
                unique_styles_to_fetch.append(p)

        print(f"After de-duplication: final product count: {len(unique_styles_to_fetch)}")

        # batch fetch full product details
        all_detailed_products = await fetch_product_batches(unique_styles_to_fetch)

        # final deduplication to ensure data integrity
        seen_main_ids = set()
        final_products = []
        for p in all_detailed_products:
            ref_id = p["id"]
            if ref_id and ref_id not in seen_main_ids:
                seen_main_ids.add(ref_id)
                final_products.append(p)

        print(f"After second de-duplication: final product count:{len(final_products)}")
        return final_products

    except Exception as e:
        print(f"Critical error in Zara sync: {e}")
        raise Exception(f"Zara sync halted: {e}")

# extract basic ID and price from product groups
def unify_product_from_product_groups(group, category_id):
    unified = []
    for element in group.get("elements", []):
        for comp in element.get("commercialComponents", []):
            # skip non-individual products
            if comp.get("type") == "Bundle":
                continue
            
            unified.append({
                "id": str(comp.get("id")),
                "category_id": category_id,
                "price": format_price(comp.get("price"))
            })
    return unified

# handles batching the detailed product requests
async def fetch_product_batches(unique_list):
    all_products = []
    batch_urls = []
    batch_metadata = [] 

    print(f"Fetching product details for {len(unique_list)} products...")

    # split the unique list into manageable chunks based on BATCH_SIZE
    for i in range(0, len(unique_list), BATCH_SIZE):
        batch = unique_list[i:i + BATCH_SIZE]
        # construct the URL with multiple productIds parameters
        ids_str = "&".join(f"productIds={p['id']}" for p in batch)
        batch_urls.append(f"{PRODUCT_DETAILS_URL}?{ids_str}&ajax=true")
        batch_metadata.append(batch)
    
    print(f"Executing {len(batch_urls)} batched detail requests...")
    # fetch batch detail results
    batch_results = await fetch_batch_json(batch_urls, HEADERS)
    
    if batch_results is None:
        raise Exception("Failed to fetch Zara product detail batches")

    for i, result in enumerate(batch_results):
        if not result or not isinstance(result, list):
            continue
            
        # match response back to the metadata (category_id/price) sent in request
        original_batch_request = batch_metadata[i]
        
        for j, product_data in enumerate(result):
            if not product_data or product_data.get("type") == "Bundle":
                continue
            
            # use metadata if the API response order matches the request order
            if j < len(original_batch_request):
                meta = original_batch_request[j]
                all_products.append(unify_product_from_flat_array(
                    product_data, 
                    meta['category_id'], 
                    meta['price']
                ))
    
    return all_products

# final transformation of raw Zara details into unified format
def unify_product_from_flat_array(data, category_id=None, initial_price=None):
    detail_data = data.get("detail", {})
    colors = detail_data.get("colors", [])

    # use initial price from category view as fallback
    final_price = initial_price
    if final_price is None and colors:
        final_price = format_price(colors[0].get("price"))
    
    # get the description from the first color entry per provided JSON
    description = ""
    if colors:
        description = colors[0].get("description", "")

    product_url = build_zara_product_url(data.get("name"), detail_data)

    return {
        "id": str(data.get("id")),
        "reference": detail_data.get("displayReference"),
        "name": data.get("name"),
        "gender": data.get("sectionName"),
        "price": final_price,
        "category_id": category_id,
        "family": data.get("familyName"),
        "subfamily": data.get("subfamilyName"),
        "seo": data.get("seo", {}).get("keyword"),
        "url": product_url,
        "description": description,
        "variants": [
            {
                "color_id": str(c.get("id")), 
                "color_name": c.get("name"),
                "hex_code": c.get("hexCode"),
                "images": [
                    {
                        "imageId": img.get("extraInfo", {}).get("assetId") or img.get("name"),
                        "url": img.get("extraInfo", {}).get("deliveryUrl") or img.get("url"),
                        "width": img.get("width"),
                        "height": img.get("height"),
                        "order": idx + 1 
                    } 
                    for idx, img in enumerate(
                        sorted(
                            [i for i in c.get("xmedia", []) if i.get("url")],
                            key=lambda x: x.get("extraInfo", {}).get("originalName") != "e1"
                        )
                    )
                ],
                "sizes": [
                    {
                        "size_name": s.get("name"),
                        "availability": s.get("availability"),
                        "price": format_price(s.get("price"))
                    } for s in c.get("sizes", [])
                ]
            } for c in colors
        ]
    }