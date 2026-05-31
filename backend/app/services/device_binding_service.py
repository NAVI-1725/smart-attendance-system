# backend\app\services\device_binding_service.py
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from app.models.device import Device
from app.models.user import User
from app.core.errors import ApiError, ErrorCode


class DeviceBindingService:
    def __init__(self, db: Session):
        self.db = db

    def bind_device(self, user: User, device_id: str):
        device_id = device_id.strip().lower()

        existing_device = (
            self.db.query(Device)
            .filter(Device.user_id == user.id, Device.is_active )
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

            try:
                self.db.commit()
            except IntegrityError:
                self.db.rollback()

                raise ApiError(
                    ErrorCode.DEVICE_BINDING_CONFLICT,
                    (
                        "This account is already registered on another device. "
                        "Please contact the academic office to reset device access."
                    ),
                    status_code=409,
                )

            return

        # Case 2: Same device → allow
        if existing_device.device_id == device_id:
            return

        # Case 3: Different device → BLOCK
        raise ApiError(
            ErrorCode.DEVICE_BINDING_CONFLICT,
            (
                "This account is already registered on another device. "
                "Please contact the academic office to reset device access."
            ),
            status_code=403,
        )
