from pydantic import BaseModel
from typing import List, Optional

class ProductRequest(BaseModel):
    menu_category_id:int
    subcategory_id: Optional[int] = None
    color_ids: List[int] = []  
    size_ids: List[int] = []   
    brand_ids: List[int] = []
    sort_by: str = "newest"
    page: int = 1
    page_size: int = 20