# Base URLs
ZARA_BASE_URL = "https://www.zara.com/lb/en/"
CATEGORIES_URL = f"{ZARA_BASE_URL}categories?configId=&ajax=true"
PRODUCT_GROUPS_URL = f"{ZARA_BASE_URL}category/{{category_id}}/products?ajax=true"
PRODUCT_DETAILS_URL = f"{ZARA_BASE_URL}products-details"

HEADERS = {
    "accept": "*/*",
    "accept-language": "en-US,en;q=0.9",
    "referer": "https://www.zara.com/lb/",
    "sec-ch-ua": '"Google Chrome";v="141", "Not?A_Brand";v="8", "Chromium";v="141"',
    "sec-ch-ua-mobile": "?0",
    "sec-ch-ua-platform": '"Windows"',
    "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
                  "(KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36",
}

MAIN_SECTIONS = {"WOMAN", "MAN"}

# Product processing
BATCH_SIZE = 10