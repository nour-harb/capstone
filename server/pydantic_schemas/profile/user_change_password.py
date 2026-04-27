# user_change_password.py
from pydantic import BaseModel

class ChangePassword(BaseModel):
    old_password: str
    new_password: str