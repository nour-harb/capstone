from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional, Tuple



@dataclass
class TurnContext:
    """Request-scoped chat turn: vision cache, product accumulation, and DB pending fields."""

    user_id: str
    products_per_turn: List[Dict[str, Any]] = field(default_factory=list)
    uploaded_image: Optional[Tuple[bytes, str]] = None
    selected_color_filter_ids: List[int] = field(default_factory=list)

    def add_color_filter_id(self, filter_id: int) -> None:
        if filter_id in self.selected_color_filter_ids:
            return
        self.selected_color_filter_ids.append(filter_id)

    def accumulate_unique_products(self, products: List[Dict[str, Any]]) -> None:
        if not products:
            return
        seen = {p.get("id") for p in self.products_per_turn}
        for p in products:
            pid = p.get("id")
            if pid is not None and pid not in seen:
                seen.add(pid)
                self.products_per_turn.append(p)

    def get_products_per_turn(self) -> List[Dict[str, Any]]:
        return list(self.products_per_turn)

    def set_uploaded_image(self, payload: Optional[Tuple[bytes, str]]) -> None:
        self.uploaded_image = payload

    def get_uploaded_image(self) -> Optional[Tuple[bytes, str]]:
        return self.uploaded_image

    def set_products_per_turn(self, products: List[Dict[str, Any]]) -> None:
        self.products_per_turn = products
