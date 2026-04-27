from pydantic import BaseModel
from typing import List, Optional

from pydantic_schemas.products.product_details.color_variant import ColorVariantSchema


class ProductDetailResponse(BaseModel):
    id: int
    product_id: str
    name: str
    description: Optional[str] = None
    price: float
    brand: str
    url: Optional[str] = None
    colors: List[ColorVariantSchema]
    favorited: Optional[bool] = None