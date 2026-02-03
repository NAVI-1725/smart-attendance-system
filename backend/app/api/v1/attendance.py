# backend\app\api\v1\attendance.py
from fastapi import APIRouter, Depends
import logging
from sqlalchemy.orm import Session as DBSession
from app.db.session import get_db
from app.core.auth import get_current_user
from app.models.user import User
from app.models.session import Session
from app.models.attendance import AttendanceAttempt
from app.models.attendance_ble_evidence import AttendanceBleEvidence
from app.schemas.attendance import AttendanceAttemptRequest
from app.services.attendance_flagging import classify_attendance


router = APIRouter(tags=["Attendance"])
logger = logging.getLogger(__name__)


@router.post("/attempt")
def submit_attendance(
    data: AttendanceAttemptRequest,
    db: DBSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    # 🔒 Ensure an active session exists (request-scoped DB)
    session = (
        db.query(Session)
        .filter(Session.is_active == True)
        .first()
    )

    if not session:
        return {"status": "no_active_session"}

    # ✅ BLE evidence is now accepted (or None)
    logger.info(
        "BLE evidence received",
        extra={"ble": data.ble_evidence},
    )

    # Deterministic status assignment (must occur BEFORE flush to satisfy NOT NULL DB constraint)
    status = classify_attendance(data.ble_evidence)

    # Create attendance row WITH status to avoid NULL insert
    attendance = AttendanceAttempt(status=status)
    db.add(attendance)
    db.flush()  # ensures attendance.id is available

    # Optional BLE evidence persistence
    if data.ble_evidence is not None:
        ble_row = AttendanceBleEvidence(
            attendance_id=attendance.id,
            ble_payload=data.ble_evidence.dict(),
        )
        db.add(ble_row)

    db.commit()
    db.refresh(attendance)

    return {
        "status": "accepted",
        "session_id": data.session_id,
    }
