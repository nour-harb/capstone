# user_change_password.py
from pydantic import BaseModel

class DeleteAccount(BaseModel):
    password: str