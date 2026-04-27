from pgvector.sqlalchemy import Vector
from sqlalchemy import (
    JSON, Column, String, Integer, Boolean, ForeignKey,
    DateTime, Index 
)
from sqlalchemy.orm import relationship

from utils.date_time_now import now_utc
from ..base import Base

class Subcategory(Base):
    __tablename__ = "subcategories"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(150), nullable=False)
    menu_category_id = Column(Integer, ForeignKey("menu_categories.id", ondelete="CASCADE"), nullable=False)
    embedding= Column(Vector(768))
    visual_prompt = Column(String(255))
    is_active = Column(Boolean, default=True)
    keywords = Column(JSON)
    created_at = Column(DateTime, default=now_utc)
    updated_at = Column(DateTime, default=now_utc, onupdate=now_utc)

    # relationships
    menu_category = relationship("MenuCategory", back_populates="subcategories")

    # indexes
    __table_args__ = (
        Index('ix_subcategory_menu_active', 'menu_category_id', 'is_active'),
        Index('ix_subcategory_name', 'name'),
    )