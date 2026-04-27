from sqlalchemy import (
    Column, ForeignKey, String, Integer, Boolean, 
    DateTime, Index
)
from sqlalchemy.orm import relationship

from utils.date_time_now import now_utc
from ..base import Base

from pgvector.sqlalchemy import Vector

class ProductColor(Base):
    __tablename__ = "product_colors"

    id = Column(Integer, primary_key=True, autoincrement=True)
    product_id = Column(Integer, ForeignKey("products.id", ondelete="CASCADE"), nullable=False)
    
    external_color_id = Column(String, index=True) 
    
    name = Column(String(100), nullable=True) # external name
    hexcode = Column(String(12), nullable=True)
    
    embedding = Column(Vector(768)) 
    color_filter_id = Column(Integer, ForeignKey("color_filters.id", ondelete="SET NULL"), nullable=True)
    
    is_active = Column(Boolean, default=True, index=True)
    created_at = Column(DateTime, default=now_utc)
    updated_at = Column(DateTime, default=now_utc, onupdate=now_utc)
    last_scraped_at = Column(DateTime, default=now_utc)

    # Relationships
    product = relationship("Product", back_populates="product_colors")
    color_filter = relationship("ColorFilter", back_populates="product_colors")
    images = relationship("Image", back_populates="product_color", cascade="all, delete-orphan")
    variants = relationship("ProductVariant", back_populates="product_color", cascade="all, delete-orphan")

    # Indexes
    __table_args__ = (
        Index('ix_product_color_external', 'product_id', 'external_color_id'),
    )