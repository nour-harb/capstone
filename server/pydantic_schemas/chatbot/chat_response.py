from typing import List, Optional
from pydantic import BaseModel
from pydantic_schemas.products.product_response import ProductResponse


class ChatResponse(BaseModel):
    reply: str
    products: List[ProductResponse] = []
    image_attachment_id: Optional[str] = None
