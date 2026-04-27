import os
from typing import Dict, List, Optional
from fastapi import APIRouter, Depends, HTTPException, Request
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from database import get_db
from middleware.auth_middleware import auth_middleware
from models import (
    ChatMessage,
    ChatMessageContext,
    ChatMessageProduct,
    ChatUploadedImage,
)
from pydantic_schemas.chatbot.chat_message_schema import ChatMessageSchema
from pydantic_schemas.chatbot.chat_request import ChatRequest
from pydantic_schemas.chatbot.chat_response import ChatResponse
from chatbot.fashion_agent import run_fashion_assistant
from utils.chat_route_utils import get_products_for_chat, save_chat_image

router = APIRouter()

# message received
@router.post("/", response_model=ChatResponse)
async def chat(
    request: Request,
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware),
):
    user_id = user_dict["uid"]
    ct = (request.headers.get("content-type") or "").lower()
    image_attachment_id: Optional[str] = None
    message = ""

    if "multipart/form-data" in ct:
        form = await request.form()
        message = str(form.get("message") or "")
        upload = form.get("image")
        if upload is not None and hasattr(upload, "filename") and upload.filename:
            image_attachment_id = await save_chat_image(user_id, upload, db)
            db.commit()
    elif "application/json" in ct:
        try:
            body = await request.json()
        except Exception:
            raise HTTPException(status_code=400, detail="Invalid JSON body")
        payload = ChatRequest(**body)
        message = payload.message
    else:
        raise HTTPException(
            status_code=415,
            detail="Content-Type must be application/json or multipart/form-data",
        )

    (
        reply_text,
        product_ids,
        color_filter_ids,
        _,
    ) = await run_fashion_assistant(
        db=db,
        user_input=message,
        user_id=user_id,
        image_attachment_id=image_attachment_id,
    )

    products = get_products_for_chat(
        db, product_ids, color_filter_ids if color_filter_ids else None
    )
    return ChatResponse(
        reply=reply_text,
        products=products,
        image_attachment_id=image_attachment_id,
    )

# return uploaded image for the frontend
@router.get("/attachments/{attachment_id}")
def get_chat_attachment(
    attachment_id: str,
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware),
):
    user_id = user_dict["uid"]
    row = (
        db.query(ChatUploadedImage)
        .filter(
            ChatUploadedImage.id == attachment_id,
            ChatUploadedImage.user_id == user_id,
        )
        .first()
    )
    if row is None:
        raise HTTPException(status_code=404, detail="Attachment not found")
    # ensure file really exists before sending it
    path = row.file_path
    if not path or not os.path.isfile(path):
        raise HTTPException(status_code=404, detail="File missing")
    return FileResponse(
        path,
        media_type=row.mime_type,
        filename=f"chat-{attachment_id}",
    )

# clear all messages and uploads for the current user
@router.delete("/")
def clear_user_chat(
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware),
):
    user_id = user_dict["uid"]
    # messages first — cascades to chat_message_products, chat_message_contexts
    deleted_msgs = (
        db.query(ChatMessage)
        .filter(ChatMessage.user_id == user_id)
        .delete(synchronize_session=False)
    )
    img_rows = (
        db.query(ChatUploadedImage)
        .filter(ChatUploadedImage.user_id == user_id)
        .all()
    )
    (
        db.query(ChatUploadedImage)
        .filter(ChatUploadedImage.user_id == user_id)
        .delete(synchronize_session=False)
    )
    db.commit()
    return {"deleted_messages": deleted_msgs, "deleted_image_rows": len(img_rows)}

# get messages for the current user's single thread
@router.get("/history", response_model=List[ChatMessageSchema])
def get_history(
    db: Session = Depends(get_db),
    user_dict: dict = Depends(auth_middleware),
):
    user_id = user_dict["uid"]
    messages = (
        db.query(ChatMessage)
        .filter(ChatMessage.user_id == user_id)
        .order_by(ChatMessage.created_at.asc(), ChatMessage.id.asc())
        .all()
    )

    msg_ids = []
    for m in messages:
        if (m.content or "").strip():
            msg_ids.append(m.id)
        elif (m.image_attachment_id) and (m.role or "") == "user":
            msg_ids.append(m.id)

    if not msg_ids:
        return []

    products_by_msg: Dict[int, List[int]] = {}
    rows = (
        db.query(ChatMessageProduct)
        .filter(ChatMessageProduct.chat_message_id.in_(msg_ids))
        .all()
    )
    for r in rows:
        products_by_msg.setdefault(r.chat_message_id, []).append(int(r.product_id))

    contexts = (
        db.query(ChatMessageContext)
        .filter(ChatMessageContext.chat_message_id.in_(msg_ids))
        .all()
    )
    color_ids_by_msg = {c.chat_message_id: c.selected_color_filter_ids for c in contexts}

    hydrated = []
    for m in messages:
        content = (m.content or "").strip()
        if not content and not (
            m.image_attachment_id and (m.role or "") == "user"
        ):
            continue
        prod_ids = products_by_msg.get(m.id, [])
        selected_colors = color_ids_by_msg.get(m.id, [])
        hydrated.append(
            {
                "id": m.id,
                "role": m.role,
                "content": content,
                "products": get_products_for_chat(db, prod_ids, selected_colors)
                if (m.role or "") == "assistant"
                else [],
                "image_attachment_id": m.image_attachment_id,
            }
        )
    return hydrated
