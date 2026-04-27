from sqlalchemy import Column, Integer, String, ForeignKey, UniqueConstraint
from ..base import Base

class BrandColorMap(Base):
    __tablename__ = "brand_color_maps"

    id = Column(Integer, primary_key=True, index=True)
    brand_id = Column(Integer, ForeignKey("brands.id"), nullable=False)
    color_name = Column(String, nullable=False, index=True)    
    color_filter_id = Column(Integer, ForeignKey("color_filters.id"), nullable=False)

    __table_args__ = (
        UniqueConstraint('brand_id', 'color_name', name='_brand_color_uc'),
    )