from pydantic import BaseModel


class DeviceBindRequest(BaseModel):
    device_id: str
