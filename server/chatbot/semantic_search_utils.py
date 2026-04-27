import numpy as np
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field
from requests import Session
from models.products.product import Product
from utils.hugging_face_utils import get_embedding_from_hf

class SemanticSearchInput(BaseModel):
    text_query: Optional[str] = Field(
        None,
        description=(
            "Short vibe/occasion/style phrase for text-based re-ranking. "
            "Required when use_uploaded_image_embedding is false. Optional when true (combines with image embedding)."
        ),
    )
    use_uploaded_image_embedding: bool = Field(
        False,
        description=(
            "If true, re-rank using the current turn's uploaded photo embedding via HF (optional text_query combined). "
            "Use on photo turns after StructuredSearch. Always full embedding re-rank (not the no-vibe shortcut)."
        ),
    )

def cosine_similarity(vec1: List[float], vec2: List[float]) -> float:
    try:
        v1, v2 = np.array(vec1), np.array(vec2)
        norm_product = np.linalg.norm(v1) * np.linalg.norm(v2)
        if norm_product == 0:
            return 0.0
        return float(np.dot(v1, v2) / norm_product)
    except Exception as e:
        print(f"Error in cosine similarity: {e}")
        return 0.0

async def rank_products_by_query_vector(db: Session, results: List[Dict[str, Any]], query_vec: List[float]) -> List[Dict[str, Any]]:
    if not results or query_vec is None:
        return results
    try:
        ids = [p.get("id") for p in results]
        if ids:
            db_products = db.query(Product).filter(Product.id.in_(ids)).all()
            prod_by_id = {p.id: p for p in db_products}
        else:
            prod_by_id = {}
        for item in results:
            prod = prod_by_id.get(item.get("id"))
            if getattr(prod, "embedding", None) is not None:
                emb = getattr(prod, "embedding", None)
            else:
                emb = None
                return results
            if emb is not None and len(emb) > 0:
                item["score"] = cosine_similarity(query_vec, emb)
            else:
                item["score"] = 0.0
        out = sorted(results, key=lambda x: x["score"], reverse=True)
        return out
    except Exception as e:
        return results
    
async def semantic_search_logic(db: Session, results: List[Dict], text_query: str) -> List[Dict]:
    if not results:
        return []
    try:
        query_vec = await get_embedding_from_hf(text_query=text_query)
        if  query_vec is None:
            return results
        return await rank_products_by_query_vector(db, results, query_vec)
    except Exception as e:
        return results