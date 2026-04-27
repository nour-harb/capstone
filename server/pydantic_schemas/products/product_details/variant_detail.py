from pydantic import BaseModel
from pydantic_schemas.products.filter_item import FilterItem


class VariantDetailSchema(BaseModel):
    id: int  
    size: FilterItem 
    price: float
    availability: str