from datetime import datetime

from sqlalchemy import (
    Boolean,
    Column,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    String,
    UniqueConstraint,
)
from sqlalchemy.orm import relationship

from .base import Base


class UserFavorite(Base):
    __tablename__ = "user_favorites"
    __table_args__ = (
        UniqueConstraint("user_id", "product_id", name="uq_user_favorite_user_product"),
    )

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(
        String(255),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    product_id = Column(
        Integer,
        ForeignKey("products.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    price_at_add = Column(Float, nullable=False)
    current_price = Column(Float, nullable=True)
    notified = Column(Boolean, default=True, nullable=False)

    product = relationship(
        "Product",
        foreign_keys=[product_id],
        backref="user_favorites",
    )
