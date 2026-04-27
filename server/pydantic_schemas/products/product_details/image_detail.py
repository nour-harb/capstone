from pydantic import BaseModel


class ImageDetailSchema(BaseModel):
    url: str