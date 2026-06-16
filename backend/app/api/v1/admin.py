# backend\app\api\v1\admin.py
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import or_

from app.core.dependencies import require_admin
from app.db.session import get_db

from app.models.user import User

from app.schemas.device import (
    DeviceUnbindRequest,
    DeviceSearchResponse,
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


@router.get(
    "/device/search",
    response_model=list[DeviceSearchResponse],
)
def search_users(
    query: str,
    db: Session = Depends(get_db),
):
    search = f"%{query.strip()}%"

    users = (
        db.query(User)
        .filter(
            or_(
                User.full_name.ilike(search),
                User.email.ilike(search),
            )
        )
        .limit(20)
        .all()
    )

    return users


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