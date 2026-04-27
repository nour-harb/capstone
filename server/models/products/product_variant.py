from sqlalchemy import (
    Column, String, Integer, Float, Boolean, ForeignKey,
    DateTime, UniqueConstraint, Index
)
from sqlalchemy.orm import relationship

from utils.date_time_now import now_utc
from ..base import Base

class ProductVariant(Base):
    __tablename__ = "product_variants"

    id = Column(Integer, primary_key=True, autoincrement=True)
    
    product_color_id = Column(Integer, ForeignKey("product_colors.id", ondelete="CASCADE"), nullable=False)
    
    size_id = Column(Integer, ForeignKey("size_master.id", ondelete="SET NULL"), nullable=True)
    
    price = Column(Float, nullable=True)
    availability = Column(String(50), nullable=True)
    is_active = Column(Boolean, default=True)
    
    created_at = Column(DateTime, default=now_utc)
    updated_at = Column(DateTime, default=now_utc, onupdate=now_utc)
    last_scraped_at = Column(DateTime, default=now_utc)

    # Relationships
    product_color = relationship("ProductColor", back_populates="variants")
    size = relationship("SizeMaster")

    __table_args__ = (
        UniqueConstraint("product_color_id", "size_id", name="uq_color_variant_size"),
        Index("ix_variants_active_lookup", "product_color_id", "is_active"),
    )