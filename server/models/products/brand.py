from sqlalchemy import (
    Column, String, Integer,  Boolean, 
    DateTime
)
from sqlalchemy.orm import relationship

from utils.date_time_now import now_utc

from ..base import Base

class Brand(Base):
    __tablename__ = "brands"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(100), unique=True, nullable=False)
    website = Column(String(255))
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=now_utc)
    updated_at = Column(DateTime, default=now_utc, onupdate=now_utc)
    
    # relationships
    products = relationship("Product", back_populates="brand")
    categories = relationship("Category", back_populates="brand") 
