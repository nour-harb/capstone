from pgvector.sqlalchemy import Vector
from sqlalchemy import (
    JSON, Column, String, Integer, Boolean, 
    DateTime, Index
)
from sqlalchemy.orm import relationship

from utils.date_time_now import now_utc
from ..base import Base

class MenuCategory(Base):
    __tablename__ = "menu_categories"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(100), nullable=False)
    gender = Column(String(20), nullable=False)  
    is_active = Column(Boolean, default=True)
    keywords = Column(JSON)
    embedding = Column(Vector(768))
    visual_prompt = Column(String(255))
    created_at = Column(DateTime, default=now_utc)
    updated_at = Column(DateTime, default=now_utc, onupdate=now_utc)

    # relationships
    subcategories = relationship("Subcategory", back_populates="menu_category", cascade="all, delete-orphan")

    # idexes
    __table_args__ = (
        Index('ix_menu_cat_gender_name', 'gender', 'name'),
    )