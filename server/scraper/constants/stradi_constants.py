BRAND_NAME = "Stradivarius"

STRADI_BASE_URL = "https://www.stradivarius.com/lb/"
STRADI_CATEGORIES_URL =f"https://www.stradivarius.com/itxrest/2/catalog/store/55009583/50331174/category?languageId=-1&typeCatalog=1&appId=1"
STRADI_PRODUCTS_URL = f"https://www.stradivarius.com/itxrest/3/catalog/store/55009583/50331174/category/{{category_id}}/product"
STRADI_PRODUCT_DETAILS_URL = f"https://www.stradivarius.com/itxrest/3/catalog/store/55009583/50331174/productsArray"

HEADERS = {
    'authority': 'www.stradivarius.com',
    'accept': '*/*',
    'accept-encoding': 'gzip, deflate, br, zstd',
    'accept-language': 'en-US,en;q=0.9',
    'content-type': 'application/json',
    'cookie': 'StradivariusGenderCategoryKey=STRADIVARIUS_WOMAN;',
    'referer': 'https://www.stradivarius.com/',
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
    'pricefilter': 'true', 
    'appId': '1',
}

BATCH_SIZE = 20

STRADI_CONFIG = {
    "BRAND_NAME": BRAND_NAME,
    "BASE_URL": STRADI_BASE_URL,
    "CATEGORIES_URL": STRADI_CATEGORIES_URL,
    "PRODUCTS_URL": STRADI_PRODUCTS_URL,
    "PRODUCT_DETAILS_URL": STRADI_PRODUCT_DETAILS_URL,
    "HEADERS": HEADERS,
    "PARAMS": PARAMS,
    "BATCH_SIZE": BATCH_SIZE
}