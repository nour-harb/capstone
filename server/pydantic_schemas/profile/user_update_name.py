from pydantic import BaseModel

class NameUpdate(BaseModel):
    new_name: str

