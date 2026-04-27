import json
from typing import List, Optional
from langchain_core.messages import AIMessage, BaseMessage, HumanMessage
from sqlalchemy.orm import Session
from models.chat_message import ChatMessage
from models.chat_message_product import ChatMessageProduct
from models.chat_message_context import ChatMessageContext

# return all messages in conversation for chatbot to have context
def load_conversation_for_agent(db: Session, user_id: str) -> List[BaseMessage]:
    rows = (
        db.query(ChatMessage)
        .filter(ChatMessage.user_id == user_id)
        .order_by(ChatMessage.created_at.asc(), ChatMessage.id.asc())
        .all()
    )
    out: List[BaseMessage] = []
    for row in rows:
        raw = row.content or ""
        if row.role == "assistant":
            out.append(AIMessage(content=raw))
        else:
            text = raw
            aid = row.image_attachment_id
            if aid:
                text = f"[User attached image attachment_id={aid}]\n{text}"
            out.append(HumanMessage(content=text))
    return out

def save_chat_turn(
    db: Session,
    user_id: str,
    user_content: str,
    image_attachment_id: Optional[str],
    reply_text: str,
    product_ids: List[int],
    color_filter_ids: List[int],
) -> int:

    if not user_content and image_attachment_id:
        user_content = "(photo)"

    user_msg = ChatMessage(
        user_id=user_id,
        role="user",
        content=user_content,
        image_attachment_id=image_attachment_id,
    )
    assistant_msg = ChatMessage(
        user_id=user_id,
        role="assistant",
        content=reply_text,
    )
    db.add(user_msg)
    db.add(assistant_msg)
    db.flush()
    assistant_id = assistant_msg.id
    if product_ids:
        db.add_all(
            [
                ChatMessageProduct(
                    chat_message_id=assistant_id,
                    product_id=int(pid),
                )
                for pid in product_ids
            ]
        )
    if color_filter_ids:
        db.add(
            ChatMessageContext(
                chat_message_id=assistant_id,
                selected_color_filter_ids_json=json.dumps(color_filter_ids),
            )
        )
    db.commit()
    db.refresh(assistant_msg)
    return assistant_id

