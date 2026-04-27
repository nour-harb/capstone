from pgvector.sqlalchemy import Vector
from sqlalchemy import (
    Column, Float, String, Integer, Boolean, ForeignKey,
    DateTime, Text, Index
)
from sqlalchemy.orm import relationship

from utils.date_time_now import now_utc
from ..base import Base

class Product(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, autoincrement=True)
    product_id = Column(String, nullable=False) 
    name = Column(String(255), nullable=False)
    price = Column(Float) 
    brand_id = Column(Integer, ForeignKey("brands.id", ondelete="SET NULL"))
    
    category_id = Column(Integer, ForeignKey("categories.id", ondelete="SET NULL"))
    menu_category_id = Column(Integer, ForeignKey("menu_categories.id", ondelete="SET NULL"))
    subcategory_id = Column(Integer, ForeignKey("subcategories.id", ondelete="SET NULL"), nullable=True)
    style_id = Column(Integer, ForeignKey("styles.id", ondelete="SET NULL"), nullable=True)
    
    gender = Column(String(100), nullable=True) 
    seo = Column(String(255), nullable=True)
    url = Column(String(1024), nullable=True)
    description = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True) 
    
    embedding = Column(Vector(768), nullable=True) 

    created_at = Column(DateTime, default=now_utc)
    updated_at = Column(DateTime, default=now_utc, onupdate=now_utc)
    last_scraped_at = Column(DateTime, default=now_utc)

    # Relationships
    brand = relationship("Brand", back_populates="products")
    category = relationship("Category", back_populates="products")
    
    product_colors = relationship("ProductColor", back_populates="product", cascade="all, delete-orphan")
    images = relationship("Image", back_populates="product", cascade="all, delete-orphan")
    
    # Indexes
    __table_args__ = (
        Index("ix_products_brand_style", "brand_id", "product_id"),
        Index("ix_products_category_id", "category_id"),
        Index("ix_products_gender", "gender"),
        Index("ix_products_active_status", "is_active", "brand_id"),
        Index("ix_products_price", "price"),
        Index("ix_products_menu_category", "menu_category_id"),
        Index("ix_products_subcategory", "subcategory_id"),
    )