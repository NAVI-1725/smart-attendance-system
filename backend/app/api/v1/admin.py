# backend\app\api\v1\admin.py
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.dependencies import require_admin
from app.db.session import get_db

from app.schemas.device import (
    DeviceUnbindRequest,
)

from app.services.device_binding_service import (
    DeviceBindingService,
)

router = APIRouter(
    prefix="/admin",
    tags=["admin"],
    dependencies=[Depends(require_admin)],
)


@router.get("/ping")
def admin_ping():
    return {"status": "admin ok"}


@router.post("/device/unbind")
def unbind_device(
    data: DeviceUnbindRequest,
    db: Session = Depends(get_db),
):
    DeviceBindingService(
        db,
    ).unbind_device(
        data.student_id,
    )

    return {
        "message":
            "Device unbound successfully",
    }