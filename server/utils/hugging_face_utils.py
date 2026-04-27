import asyncio
import httpx
import os
import random
from typing import List, Optional
from dotenv import load_dotenv

load_dotenv()

AI_REQUEST_LIMITER = asyncio.Semaphore(5)
HF_SPACE_URL = os.getenv("HF_SPACE_URL")

# try images until we get a valid embedding
async def get_embedding_with_image_retry(image_list: list, text_query: str):
    for img_data in image_list:
        url = img_data.get("url")
        if not url:
            continue

        try:
            embedding = await get_embedding_from_hf(image_url=url, text_query=text_query)
            if embedding:
                return embedding
        except Exception as e:
            if "cannot identify image file" in str(e).lower():
                continue
            print(f"Error processing image {url}: {e}")

    return None

# sends request to HF space to get emebdding for text+image using image URL or bytes 
async def get_embedding_from_hf(
    image_url: str = "",
    text_query: str = "",
    image_bytes: Optional[bytes] = None,
    image_mime: str = "image/jpeg",
) -> Optional[List[float]]:
    
    if not image_url and not text_query and not image_bytes:
        return None

    max_retries = 3
    base_delay = 2

    for attempt in range(max_retries):
        try:
            async with AI_REQUEST_LIMITER:
                async with httpx.AsyncClient(timeout=60.0) as client:
                    
                    # multi-part POST (for raw image bytes)
                    if image_bytes:
                        fields = {"text_query": text_query}
                        files = {
                            "image": ("upload", image_bytes, image_mime)
                        }
                        
                        response = await client.post(
                            HF_SPACE_URL,
                            data=fields,  
                            files=files  
                        )
                    
                    # standard GET 
                    else:
                        params = {}
                        if image_url: params["url"] = image_url
                        if text_query: params["text_query"] = text_query
                        
                        response = await client.get(HF_SPACE_URL, params=params)

                    if response.status_code == 200:
                        data = response.json()

                        if "error" in data:
                            print(f"AI Space Logic Error: {data['error']}")
                            return None

                        vector = data.get("vector")
                        if vector and len(vector) == 768:
                            return vector
                    else:
                        print(f"AI Space Server Error [{response.status_code}]. Retrying...")

        except (httpx.ConnectError, httpx.TimeoutException, httpx.RequestError) as e:
            if attempt < max_retries - 1:
                wait_time = (base_delay * (attempt + 1)) + random.uniform(0, 1)
                print(f"Connection failed ({e}). Retrying in {wait_time:.2f}s...")
                await asyncio.sleep(wait_time)
            else:
                print(f"Connection failed after {max_retries} attempts: {e}")
                return None
        except Exception as e:
            print(f"Unexpected error in get_embedding_from_hf: {e}")
            return None

    return None