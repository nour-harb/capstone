from pgvector.sqlalchemy import Vector
from sqlalchemy import (
    JSON, Column, ForeignKey, String, Integer, Boolean, 
    DateTime, Index
)
from sqlalchemy.orm import relationship

from utils.date_time_now import now_utc
from ..base import Base

class ColorFilter(Base):
    __tablename__ = "color_filters"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(100), nullable=False, unique=True) 
    hexcode = Column(String(12), nullable=True)
    keywords = Column(JSON) 
    embedding = Column(Vector(768)) 
    visual_prompt = Column(String(255))
    created_at = Column(DateTime, default=now_utc)
    updated_at = Column(DateTime, default=now_utc, onupdate=now_utc)

    # Relationships
    product_colors = relationship("ProductColor", back_populates="color_filter")

    # Fixed Indexes
    __table_args__ = (
        Index('ix_color_filters_name', 'name'),
    )