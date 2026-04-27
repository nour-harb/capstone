from sqlalchemy import (
    Column, String, Integer, Boolean, ForeignKey,
    DateTime, Index, UniqueConstraint 
)
from sqlalchemy.orm import relationship

from utils.date_time_now import now_utc
from ..base import Base

class Category(Base):
    __tablename__ = "categories"

    id = Column(Integer, primary_key=True, autoincrement=True)
    external_category_id = Column(String) 
    gender = Column(String(100))      
    category_name = Column(String(100))     
    subcategory_name = Column(String(150), nullable=True) 
    brand_id = Column(Integer, ForeignKey("brands.id", ondelete="SET NULL"), nullable=True)
    is_active = Column(Boolean, default=True, index=True)
    created_at = Column(DateTime, default=now_utc)
    updated_at = Column(DateTime, default=now_utc, onupdate=now_utc)
    last_scraped_at = Column(DateTime, default=now_utc)

    # relationships    
    products = relationship("Product", back_populates="category")
    brand = relationship("Brand", back_populates="categories")

    # indexes
    __table_args__ = (
        Index('ix_category_brand_external', 'brand_id', 'external_category_id'),
        UniqueConstraint(
            'brand_id', 'external_category_id',
            name='uq_category_brand_external'
        ),
    )