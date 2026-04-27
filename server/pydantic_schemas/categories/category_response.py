from pydantic import BaseModel

class CategoryResponse(BaseModel):
    name: str
    id: int
    gender: str