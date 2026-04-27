from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models.products.menu_category import MenuCategory
from pydantic_schemas.categories.category_response import CategoryResponse

router = APIRouter()

@router.get("/list", response_model =List[CategoryResponse])
def list_categories(db: Session = Depends(get_db)):
    categories = db.query(MenuCategory).all()

    if not categories:
        raise HTTPException(status_code=404, detail="Categories not found")

    return categories
