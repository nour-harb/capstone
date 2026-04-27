from typing import List, Optional
from pydantic import BaseModel
from pydantic_schemas.products.product_response import ProductResponse
from pydantic_schemas.products.filter_item import FilterItem



class ProductListResponse(BaseModel):
    products: List[ProductResponse]
    sizes: List[FilterItem]
    colors: List[FilterItem]
    brands:List[FilterItem]
    subcategories:List[FilterItem]
    search_id:Optional[str] = None