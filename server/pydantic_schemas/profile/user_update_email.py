from pydantic import BaseModel, EmailStr

class EmailUpdate(BaseModel):
    new_email: EmailStr
