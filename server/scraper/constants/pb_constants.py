BRAND_NAME = "PULLANDBEAR"

PULLBEAR_BASE_URL = "https://www.pullandbear.com/lb/"
PULLBEAR_CATEGORIES_URL = "https://www.pullandbear.com/itxrest/2/catalog/store/25009533/20309454/category?languageId=-1&typeCatalog=1&appId=1"
PULLBEAR_PRODUCTS_URL = "https://www.pullandbear.com/itxrest/3/catalog/store/25009533/20309454/category/{category_id}/product"
PULLBEAR_PRODUCT_DETAILS_URL = "https://www.pullandbear.com/itxrest/3/catalog/store/25009533/20309454/productsArray"



HEADERS = {
    'authority': 'www.pullandbear.com',
    'accept': '*/*',
    'accept-encoding': 'gzip, deflate, br, zstd',
    'accept-language': 'en-US,en;q=0.9',
    'content-type': 'application/json',
    'cookie': 'PullBearGenderCategoryKey=PULL_AND_BEAR_WOMAN;',
    'referer': 'https://www.pullandbear.com/',
    'sec-ch-ua': '"Google Chrome";v="141", "Not?A_Brand";v="8", "Chromium";v="141"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"Windows"',
    'sec-fetch-dest': 'empty',
    'sec-fetch-mode': 'cors',
    'sec-fetch-site': 'same-origin',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36',
}

# Query parameters
PARAMS = {
    'showProducts': 'false',
    'showNoStock': 'false', 
    'appId': '1',
    'languageId': '-1',
    'locale': 'en_US'
}

BATCH_SIZE = 20

PB_CONFIG = {
    "BRAND_NAME": BRAND_NAME,
    "BASE_URL": PULLBEAR_BASE_URL,
    "CATEGORIES_URL": PULLBEAR_CATEGORIES_URL,
    "PRODUCTS_URL": PULLBEAR_PRODUCTS_URL,
    "PRODUCT_DETAILS_URL": PULLBEAR_PRODUCT_DETAILS_URL,
    "HEADERS": HEADERS,
    "PARAMS": PARAMS,
    "BATCH_SIZE": BATCH_SIZE
}