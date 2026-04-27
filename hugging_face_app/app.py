from io import BytesIO
from typing import Optional
from fastapi import File, Form, UploadFile
import open_clip
import requests
import torch
from fastapi import FastAPI, Request
from PIL import Image

app = FastAPI()

model, _, preprocess = open_clip.create_model_and_transforms("hf-hub:Marqo/marqo-fashionSigLIP")
tokenizer = open_clip.get_tokenizer("hf-hub:Marqo/marqo-fashionSigLIP")
model = model.to("cpu")

@app.get("/")
def home():
    return {"status": "Running"}


@app.get("/embed")
def get_embedding(url: Optional[str] = None, text_query: Optional[str] = None):
    try:
        if not url and not text_query:
            return {"error": "Provide either url or text_query"}

        image_features = None
        text_features = None

        if url:
            headers = {
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            }
            response = requests.get(url, headers=headers, timeout=10)
            if response.status_code != 200:
                return {"error": f"Image access denied. Status code: {response.status_code}"}

            img = Image.open(BytesIO(response.content)).convert("RGB")
            image_input = preprocess(img).unsqueeze(0).to("cpu")
            with torch.no_grad():
                image_features = model.encode_image(image_input)

        if text_query:
            text_tokens = tokenizer([text_query]).to("cpu")
            with torch.no_grad():
                text_features = model.encode_text(text_tokens)

        if image_features is not None and text_features is not None:
            final_features = (0.3 * image_features) + (0.7 * text_features)
        elif image_features is not None:
            final_features = image_features
        elif text_features is not None:
            final_features = text_features
        else:
            return {"error": "Provide either url or text_query"}

        final_features = final_features / final_features.norm(dim=-1, keepdim=True)
        vector = final_features.cpu().numpy().tolist()[0]
        return {"vector": vector}

    except Exception as e:
        return {"error": f"Internal Error: {str(e)}"}



@app.post("/embed")
async def post_embedding(
    text_query: Optional[str] = Form(None), 
    image: Optional[UploadFile] = File(None)
):
    try:
        image_features = None
        text_features = None

        # handle the multipart image
        if image:
            # read the raw bytes
            raw = await image.read()
            img = Image.open(BytesIO(raw)).convert("RGB")
            
            image_input = preprocess(img).unsqueeze(0).to("cpu")
            with torch.no_grad():
                image_features = model.encode_image(image_input)

        if text_query:
            text_tokens = tokenizer([text_query]).to("cpu")
            with torch.no_grad():
                text_features = model.encode_text(text_tokens)

        if image_features is not None and text_features is not None:
            final_features = (0.3 * image_features) + (0.7 * text_features)
        elif image_features is not None:
            final_features = image_features
        elif text_features is not None:
            final_features = text_features
        else:
            return {"error": "Provide either text_query or an image file"}
            
        final_features = final_features / final_features.norm(dim=-1, keepdim=True)
        vector = final_features.cpu().numpy().tolist()[0]
        
        return {"vector": vector}

    except Exception as e:
        return {"error": f"Internal Error: {str(e)}"}