import base64
import json
import os
import re
import time
from typing import Any, Dict, Optional, Tuple
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.messages import HumanMessage
from requests import Session
from models.chat_uploaded_image import ChatUploadedImage
from chatbot.util import get_clean_text

# uses gemini model to determine if image contains clothing, returns is_apparel, description, and is_overloaded
async def classify_fashion_image(image_bytes: bytes, mime_type: str) -> Dict[str, Any]:

    api_key = os.getenv("GOOGLE_API_KEY")
    if not api_key:
        return {"is_apparel": False, "description": "Vision unavailable."}

    b64 = base64.b64encode(image_bytes).decode("ascii")
    data_url = f"data:{mime_type};base64,{b64}"

    llm = ChatGoogleGenerativeAI(
        # model="gemini-3.1-flash-lite-preview",
        model="gemini-2.5-flash-lite",
        temperature=0.1,
        google_api_key=api_key,
        max_output_tokens=256,
    )

    prompt = """Look at this image. You help a clothing store chatbot.
                Respond with ONLY valid JSON (no markdown):
                {"is_apparel": true or false, 
                "description": "short English phrase (4-10 words) describing visible garments/accessories or what you see"}

                Rules:
                - is_apparel = true only if the image clearly (not blurry) shows wearable clothing, shoes, bags, or fashion accessories 
                - description: describe the clothing items in detail using 4-10 words; mention item color and characteristics that would be helpful to search for
                (e.g. "blue denim jacket", "white sneakers", "red short sleeved midi dress").
                - if an image is blurry, even if you can tell it contains a clothing item, return is_apparel = false.
                """

    msg = HumanMessage(
        content=[
            {"type": "text", "text": prompt},
            {"type": "image_url", "image_url": {"url": data_url}},
        ]
    )

    try:
        resp = await llm.ainvoke([msg])
        text = get_clean_text(resp)
        return parse_json_response(text)
    except Exception as e:
        t = str(e)
        if "429" in t or "503" in t:
            return {"is_apparel": False, "description": "", "is_overloaded": True}
        return {"is_apparel": False, "description": "", "is_overloaded": False}
    
# load uploaded image from disk by ID, return (bytes, miime_type)
def load_chat_uploaded_image(db: Session, user_id: str, image_id: str) -> Optional[Tuple[bytes, str]]:
    row = (
        db.query(ChatUploadedImage)
        .filter(ChatUploadedImage.id == image_id, ChatUploadedImage.user_id == user_id)
        .first()
    )
    if not row:
        return None
    try:
        with open(row.file_path, "rb") as f:
            data = f.read()
    except OSError:
        return None
    mime = row.mime_type
    return (data, mime)

# extract JSON from model response
def parse_json_response(text: str) -> Dict[str, Any]:
    text = text.strip()
    
    try:
        data = json.loads(text)
    except json.JSONDecodeError:
        # search for the { } block
        match = re.search(r"\{[\s\S]*\}", text)
        if match:
            try:
                data = json.loads(match.group(0))
            except json.JSONDecodeError:
                return {"is_apparel": False, "description": ""}
        else:
            return {"is_apparel": False, "description": ""}

    is_apparel = bool(data.get("is_apparel", False))
    description = str(data.get("description") or "").strip()
    
    return {"is_apparel": is_apparel, "description": description}