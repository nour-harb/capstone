import bcrypt
from fastapi import Depends, HTTPException, APIRouter
from sqlalchemy.orm import Session
from database import get_db
from models.user import User
from pydantic_schemas.profile.user_update_name import NameUpdate  
from pydantic_schemas.profile.user_update_email import EmailUpdate  
from pydantic_schemas.profile.user_change_password import ChangePassword  
from middleware.auth_middleware import auth_middleware
from pydantic_schemas.profile.user_delete_account import DeleteAccount

router = APIRouter()

## update name
@router.patch("/update-name")
def update_name(
    name: NameUpdate,
    db: Session = Depends(get_db),
    user_dict=Depends(auth_middleware),
):
    user = db.query(User).filter(User.id == user_dict["uid"]).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if not name.new_name or name.new_name.strip() == "":
        raise HTTPException(status_code=400, detail="Name is required")
    
    if user.name == name.new_name:
        raise HTTPException(status_code=400, detail="New name must be different than old name")
    
    user.name = name.new_name.strip()
    db.commit()
    db.refresh(user)
    return user

## update email
@router.patch("/update-email")
def update_email(
    email: EmailUpdate,
    db: Session = Depends(get_db),
    user_dict=Depends(auth_middleware),
):
    user = db.query(User).filter(User.id == user_dict["uid"]).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if not email.new_email or email.new_email.strip() == "":
        raise HTTPException(status_code=400, detail="Email is required")

    existing = db.query(User).filter(User.email == email.new_email).first()
    if existing and existing.id != user.id:
        raise HTTPException(status_code=400, detail="Email already in use")
    
    if user.email == email.new_email:
        raise HTTPException(status_code=400, detail="New email must be different than old email")

    user.email = email.new_email.strip()
    db.commit()
    db.refresh(user)
    return user



@router.post("/change-password")
def change_password(
    passwords: ChangePassword,
    db: Session = Depends(get_db),
    user_dict=Depends(auth_middleware),
):
    user = db.query(User).filter(User.id == user_dict["uid"]).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if not bcrypt.checkpw(passwords.old_password.encode(), user.password):
        raise HTTPException(status_code=400, detail="Old password is incorrect")
    
    if passwords.old_password == passwords.new_password:
        raise HTTPException(status_code=400, detail="New password must be different than old password")

    hashed_new = bcrypt.hashpw(passwords.new_password.encode(), bcrypt.gensalt())
    user.password = hashed_new

    db.commit()
    return {"detail": "Password changed successfully"}


@router.delete("/delete")
def delete_account(
    data: DeleteAccount,  
    db: Session = Depends(get_db),
    user_dict=Depends(auth_middleware),
):
    user = db.query(User).filter(User.id == user_dict['uid']).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if not bcrypt.checkpw(data.password.encode(), user.password):
        raise HTTPException(status_code=400, detail="Password incorrect")

    db.delete(user)
    db.commit()

    return {"detail": "Account deleted successfully"}

