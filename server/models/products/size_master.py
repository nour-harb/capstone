from sqlalchemy import (
    Column, String, Integer,
    DateTime
)
from sqlalchemy.orm import relationship
from utils.date_time_now import now_utc
from ..base import Base

class SizeMaster(Base):
    __tablename__ = "size_master"

    id = Column(Integer, primary_key=True, autoincrement=True)
    code = Column(String(50), nullable=False, unique=True)  
    created_at = Column(DateTime, default=now_utc)
    updated_at = Column(DateTime, default=now_utc, onupdate=now_utc)

    # relationships
    variants = relationship("ProductVariant", back_populates="size")