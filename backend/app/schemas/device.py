# backend\app\schemas\device.py
from pydantic import BaseModel


class DeviceBindRequest(BaseModel):
    device_id: str


class DeviceUnbindRequest(BaseModel):
    student_id: int


class SelfUnbindResponse(BaseModel):
    message: str


class DeviceSearchResponse(BaseModel):
    id: int
    full_name: str
    email: str
    role: str