import bcrypt
from fastapi import Depends, HTTPException, APIRouter
import uuid
import jwt
from models.user import User
from pydantic_schemas.auth.user_create import UserCreate
from pydantic_schemas.auth.user_login import UserLogin
from database import get_db
from sqlalchemy.orm import Session
from middleware.auth_middleware import auth_middleware
from dotenv import load_dotenv
import os

router = APIRouter()

load_dotenv()

SECRET_KEY = os.getenv("SECRET_KEY")

@router.post("/signup", status_code=201)
def signup_user(user: UserCreate, db: Session=Depends(get_db)):
    user_db = db.query(User).filter(User.email == user.email).first()
    
    if user_db:
        raise HTTPException(status_code=400, detail="User with the same email already exists")
    
    hashed_password = bcrypt.hashpw(user.password.encode(), bcrypt.gensalt())
    user_db = User(id=str(uuid.uuid4()), email=user.email, name=user.name, password=hashed_password)

    db.add(user_db)
    db.commit()
    db.refresh(user_db)

    token = jwt.encode({"id": user_db.id}, SECRET_KEY)
    return {"token": token, "user": user_db}

@router.post("/signin")
def login_user(user: UserLogin, db: Session=Depends(get_db)):
    user_db = db.query(User).filter(User.email == user.email).first()

    if not user_db:
        raise HTTPException(status_code=400, detail="User with this email does not exist")
    
    is_match = bcrypt.checkpw(user.password.encode(), user_db.password)
    if not is_match:
        raise HTTPException(status_code=400, detail="Incorrect password")
    
    token = jwt.encode({"id": user_db.id}, SECRET_KEY)
    
    return {'token': token, 'user': user_db}

@router.get("/")
def current_user_data(db: Session=Depends(get_db), user_dict = Depends(auth_middleware)):  # Depends(auth_middleware)
    user = db.query(User).filter(User.id == user_dict['uid']).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return user