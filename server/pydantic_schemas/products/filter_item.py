from pydantic import BaseModel


class FilterItem(BaseModel):
    id: int
    name: str
