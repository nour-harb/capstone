from sqlalchemy import Column, ForeignKey, Integer
from sqlalchemy.orm import relationship

from .base import Base


class ChatMessageProduct(Base):
    __tablename__ = "chat_message_products"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    chat_message_id = Column(
        Integer,
        ForeignKey("chat_messages.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    product_id = Column(Integer, nullable=False, index=True)

    chat_message = relationship("ChatMessage")

