from pydantic import BaseModel
from typing import Optional

class ProductResponse(BaseModel):
    id: int
    name: str
    price: float
    brand: str
    gender: str
    menu_category_id: int
    subcategory_id: Optional[int]
    main_image_url: str
    main_color: str
    other_colors_count: int


