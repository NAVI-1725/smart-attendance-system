# backend\app\schemas\trusted_beacon.py

from pydantic import BaseModel


class TrustedBeaconCreate(BaseModel):
    classroom_id: int
    beacon_uuid: str
    beacon_name: str | None = None


class TrustedBeaconUpdate(BaseModel):
    classroom_id: int
    beacon_uuid: str
    beacon_name: str | None = None
    is_active: bool


class TrustedBeaconResponse(BaseModel):
    id: int
    classroom_id: int
    beacon_uuid: str
    beacon_name: str | None
    is_active: bool

    class Config:
        from_attributes = True