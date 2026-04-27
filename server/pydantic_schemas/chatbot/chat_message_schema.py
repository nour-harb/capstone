from typing import List, Optional
from pydantic import BaseModel
from pydantic_schemas.products.product_response import ProductResponse


class ChatMessageSchema(BaseModel):
    id: int
    role: str
    content: str
    products: List[ProductResponse] = []
    image_attachment_id: Optional[str] = None
