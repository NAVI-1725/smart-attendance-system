from sqlalchemy.orm import Session
from fastapi import HTTPException, status

from app.models.device import Device
from app.models.user import User


class DeviceBindingService:
    def __init__(self, db: Session):
        self.db = db

    def bind_device(self, user: User, device_id: str):
        existing_device = (
            self.db.query(Device)
            .filter(Device.user_id == user.id, Device.is_active == True)
            .first()
        )

        # Case 1: No device bound yet → bind
        if not existing_device:
            device = Device(
                user_id=user.id,
                device_id=device_id,
                is_active=True,
            )
            self.db.add(device)
            self.db.commit()
            return

        # Case 2: Same device → allow
        if existing_device.device_id == device_id:
            return

        # Case 3: Different device → BLOCK
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=(
                "This account is already registered on another device. "
                "Please contact the academic office to reset device access."
            ),
        )
