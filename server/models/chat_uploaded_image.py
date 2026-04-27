from datetime import datetime

from sqlalchemy import Column, DateTime, ForeignKey, String, Text

from .base import Base


class ChatUploadedImage(Base):
    """
    User-uploaded chat image stored on disk; referenced by id from messages and tools.
    """

    __tablename__ = "chat_uploaded_images"

    id = Column(String(64), primary_key=True)  # UUID hex
    user_id = Column(String(255), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    file_path = Column(Text, nullable=False)
    mime_type = Column(String(100), nullable=False, default="image/jpeg")
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
