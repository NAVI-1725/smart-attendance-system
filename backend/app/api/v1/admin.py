# backend\app\api\v1\admin.py
from fastapi import APIRouter, Depends
from app.core.dependencies import require_admin

router = APIRouter(
    prefix="/admin",
    tags=["admin"],
    dependencies=[Depends(require_admin)],
)


@router.get("/ping")
def admin_ping():
    return {"status": "admin ok"}
