from pydantic import BaseModel


class PriceDropAlertsCountResponse(BaseModel):
    affected_count: int
