from sqlalchemy import (
    Column, String, Integer, Boolean, ForeignKey,
    DateTime, Text, Index 
)
from sqlalchemy.orm import relationship

from utils.date_time_now import now_utc
from ..base import Base

class Image(Base):
    __tablename__ = "images"

    id = Column(Integer, primary_key=True, autoincrement=True)
    image_id = Column(String) 
    color_id = Column(Integer, ForeignKey("product_colors.id", ondelete="CASCADE"), nullable=True)
    product_id = Column(Integer, ForeignKey("products.id", ondelete="CASCADE"), nullable=False)
    
    image_type = Column(String(50))  
    url = Column(Text, nullable=False)
    width = Column(Integer, nullable=True)
    height = Column(Integer, nullable=True)
    order = Column(Integer, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=now_utc)
    updated_at = Column(DateTime, default=now_utc, onupdate=now_utc)
    last_scraped_at = Column(DateTime, default=now_utc)

    # Relationships
    product_color = relationship("ProductColor", back_populates="images")
    product = relationship("Product", back_populates="images")

    # Indexes
    __table_args__ = (
        Index('ix_image_product_lookup', 'product_id', 'image_id'),
        Index('ix_image_active_search', 'product_id', 'color_id', 'is_active'),
    )