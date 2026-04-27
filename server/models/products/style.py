from pgvector.sqlalchemy import Vector
from sqlalchemy import (
    JSON, Column, ForeignKey, String, Integer, Boolean, 
    DateTime, Index
)
from sqlalchemy.orm import relationship

from utils.date_time_now import now_utc
from ..base import Base

class Style(Base):
    __tablename__ = "styles"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(100), nullable=False, unique=True) 
    keywords = Column(JSON) # ["navy", "sky", "azure"]
    embedding = Column(Vector(768)) 
    visual_prompt = Column(String(255))
    created_at = Column(DateTime, default=now_utc)
    updated_at = Column(DateTime, default=now_utc, onupdate=now_utc)

    # Fixed Indexes
    __table_args__ = (
        Index('ix_styles_name', 'name'),
    )