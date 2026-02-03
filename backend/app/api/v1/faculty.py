# backend\app\api\v1\faculty.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_current_user, get_db, require_faculty
from app.models.attendance import AttendanceAttempt, AttendanceStatus
from app.models.faculty_action_logs import FacultyActionLog
from app.schemas.faculty_resolution import FacultyResolutionRequest

router = APIRouter(
    tags=["Faculty"],
    dependencies=[Depends(require_faculty)],
)


@router.post("/attendance/resolve")
def resolve_attendance(
    data: FacultyResolutionRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    # 1️⃣ Faculty-only authority (case-safe)
    if current_user.role.upper() != "FACULTY":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Faculty access required",
        )

    # 2️⃣ Attendance existence (CORRECT ORM MODEL)
    attendance = (
        db.query(AttendanceAttempt)
        .filter(AttendanceAttempt.id == data.attendance_id)
        .first()
    )

    if not attendance:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Attendance not found",
        )

    # 3️⃣ Only FLAGGED can be resolved
    if attendance.status != AttendanceStatus.FLAGGED:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only FLAGGED attendance can be resolved",
        )

    original_status = attendance.status

    # 4️⃣ Apply resolution
    attendance.status = AttendanceStatus(data.new_status)

    # 5️⃣ Immutable audit log (exam-critical)
    log = FacultyActionLog(
        faculty_id=current_user.id,
        attendance_id=attendance.id,
        original_status=original_status.value,
        new_status=data.new_status.value,
        reason=data.reason,
    )

    db.add(log)
    db.commit()

    return {"status": "resolved"}
