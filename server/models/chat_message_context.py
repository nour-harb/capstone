import json
from typing import List, Optional

from sqlalchemy import Column, ForeignKey, Integer, Text
from sqlalchemy.orm import relationship

from .base import Base


class ChatMessageContext(Base):
    __tablename__ = "chat_message_contexts"

    chat_message_id = Column(
        Integer,
        ForeignKey("chat_messages.id", ondelete="CASCADE"),
        primary_key=True,
    )
    selected_color_filter_ids_json = Column(Text, nullable=True)

    chat_message = relationship("ChatMessage")

    @property
    def selected_color_filter_ids(self) -> List[int]:
        raw = self.selected_color_filter_ids_json
        if not raw:
            return []
        try:
            parsed = json.loads(raw)
            if isinstance(parsed, list):
                return [int(x) for x in parsed if isinstance(x, (int, float, str)) and str(x).isdigit()]
        except Exception:
            return []
        return []

