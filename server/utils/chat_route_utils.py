from pathlib import Path
from typing import List, Optional
import uuid
from fastapi import UploadFile
from models.chat_uploaded_image import ChatUploadedImage
from models.products.product import Product
from models.products.product_color import ProductColor
from pydantic_schemas.products.product_response import ProductResponse
from utils.product_route_utils import format_products
from sqlalchemy.orm import Session

# fetch Products by IDs to format them same as for list_all and search (to be used in frontend by widget)
def get_products_for_chat(db: Session, product_ids: List[int], selected_color_filter_ids: Optional[List[int]] = None,) -> List[ProductResponse]:
    if not product_ids:
        return []
    products = db.query(Product).filter(
            Product.id.in_(product_ids), 
            Product.is_active == True
        ).all()
    returned_ids = {p.id: p for p in products}

    ordered_products = []
    # ensure products are in the same order the agent sent them 
    for target_id in product_ids:
        if target_id in returned_ids:
            ordered_products.append(returned_ids[target_id])
    return format_products(ordered_products, selected_color_filter_ids or [])

# assigns a path for uploaded images (locally)
def upload_dir() -> Path:
    base = Path(__file__).resolve().parent.parent
    return base / "uploads" / "chat_images"

# saves the uploaded image locally, adds it to DB, and returns its ID (uuid)
async def save_chat_image(user_id: str, upload: UploadFile, db: Session) -> str:
    extension = Path(upload.filename).suffix.lower()
    img_id = uuid.uuid4().hex
    d = upload_dir()
    d.mkdir(parents=True, exist_ok=True)
    dest = d / f"{img_id}{extension}"
    raw = await upload.read()
    dest.write_bytes(raw)
    mime = upload.content_type
    row = ChatUploadedImage(
        id=img_id,
        user_id=user_id,
        file_path=str(dest),
        mime_type=mime,
    )
    db.add(row)
    db.flush()
    return img_id
