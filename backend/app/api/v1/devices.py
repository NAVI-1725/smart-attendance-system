# backend\app\api\v1\devices.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.device import Device
from app.models.user import User
from app.core.auth import get_current_user
from app.core.errors import ApiError, ErrorCode
from app.services.device_binding_service import DeviceBindingService

router = APIRouter(tags=["Devices"])


@router.post("/bind")
def bind_device(
    payload: dict,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    device_id = payload.get("device_id")

    if not device_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="device_id is required",
        )

    # 🔍 Check if user already has a registered device
    existing_device = (
        db.query(Device)
        .filter(
            Device.user_id == current_user.id,
            Device.is_active,
        )
        .first()
    )

    # ✅ FIRST-TIME BIND (THIS WAS MISSING)
    if not existing_device:
        new_device = Device(
            user_id=current_user.id,
            device_id=device_id,
            is_active=True,
        )
        db.add(new_device)
        db.commit()
        db.refresh(new_device)

        return {"status": "device_bound"}

    # ✅ SAME DEVICE → allow silently
    if existing_device.device_id == device_id:
        return {"status": "device_verified"}

    # ❌ DIFFERENT DEVICE → reject
    raise HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail=(
            "This account is already registered on another device. "
            "Please use your registered device or contact the academic office "
            "to request a device reset."
        ),
    )


@router.post("/self-unbind")
def self_unbind_device(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role == "student":
        raise ApiError(
            ErrorCode.FORBIDDEN,
            "Students cannot reset devices",
            status_code=403,
        )

    DeviceBindingService(
        db,
    ).self_unbind_device(
        current_user.id,
    )

    return {
        "message": "Device unbound successfully",
    }