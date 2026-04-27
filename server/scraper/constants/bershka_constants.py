BRAND_NAME = "Bershka"

HEADERS = {
        'authority': 'www.bershka.com',
        'accept': '*/*',
        'accept-language': 'en-US,en;q=0.9',
        'referer': 'https://www.bershka.com/',
        'sec-ch-ua': '"Google Chrome";v="141", "Not?A_Brand";v="8", "Chromium";v="141"',
        'sec-ch-ua-mobile': '?0',
        'sec-ch-ua-platform': '"Windows"',
        'sec-fetch-dest': 'empty',
        'sec-fetch-mode': 'cors',
        'sec-fetch-site': 'same-origin',
        'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36',
    }
BERSHKA_BASE_URL = "https://www.bershka.com/lb/"
BERSHKA_CATEGORIES_URL = "https://www.bershka.com/itxrest/2/marketing/store/45109533/40259559/spot?spot=BK3_ESpot_I18N&languageId=-1&appId=1&locale=en_US"
BERSHKA_PRODUCT_IDS_URL = "https://www.bershka.com/itxrest/3/catalog/store/45109533/40259559/category/{category_id}/product"
BERSHKA_PRODUCT_DETAILS_URL = "https://www.bershka.com/itxrest/3/catalog/store/45109533/40259559/productsArray"


# Query parameters
PARAMS = {
    'showProducts': 'false',
    'showNoStock': 'false', 
    'appId': '1',
    'languageId': '-1',
    'locale': 'en_US'
}


BATCH_SIZE = 20

BERSHKA_CONFIG = {
    "BRAND_NAME": BRAND_NAME,
    "BASE_URL": BERSHKA_BASE_URL,
    "CATEGORIES_URL": BERSHKA_CATEGORIES_URL,
    "PRODUCTS_URL": BERSHKA_PRODUCT_IDS_URL,
    "PRODUCT_DETAILS_URL": BERSHKA_PRODUCT_DETAILS_URL,
    "HEADERS": HEADERS,
    "PARAMS": PARAMS,
    "BATCH_SIZE": BATCH_SIZE
}