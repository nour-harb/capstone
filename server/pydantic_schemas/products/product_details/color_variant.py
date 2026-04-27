from typing import List

from pydantic import BaseModel
from pydantic_schemas.products.product_details.image_detail import ImageDetailSchema
from pydantic_schemas.products.product_details.variant_detail import VariantDetailSchema


class ColorVariantSchema(BaseModel):
    id: int 
    name: str 
    images: List[ImageDetailSchema]
    variants: List[VariantDetailSchema]