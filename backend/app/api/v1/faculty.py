# backend\app\api\v1\faculty.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func

from app.core.dependencies import get_current_user, get_db, require_faculty
from app.core.domain_rules import ensure_faculty_owns_classroom
from app.models.attendance import AttendanceAttempt, AttendanceStatus
from app.models.faculty_action_logs import FacultyActionLog
from app.models.attendance_session import AttendanceSession
from app.schemas.faculty import AttendanceSummaryResponse
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

    # 3️⃣ Faculty must own classroom
    ensure_faculty_owns_classroom(
        db,
        current_user.id,
        attendance.classroom_id,
    )

    # 4️⃣ Only FLAGGED can be resolved
    if attendance.status != AttendanceStatus.FLAGGED:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only FLAGGED attendance can be resolved",
        )

    original_status = attendance.status

    # 5️⃣ Apply resolution
    attendance.status = AttendanceStatus(data.new_status)

    # 6️⃣ Immutable audit log (exam-critical)
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


@router.get("/sessions")
def get_faculty_sessions(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    sessions = (
        db.query(AttendanceSession)
        .filter(AttendanceSession.faculty_id == current_user.id)
        .order_by(AttendanceSession.id.desc())
        .all()
    )

    return sessions


@router.get(
    "/attendance-summary",
    response_model=AttendanceSummaryResponse,
)
def get_attendance_summary(
    classroom_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    ensure_faculty_owns_classroom(
        db,
        current_user.id,
        classroom_id,
    )

    confirmed = (
        db.query(func.count(AttendanceAttempt.id))
        .filter(
            AttendanceAttempt.classroom_id == classroom_id,
            AttendanceAttempt.status == AttendanceStatus.CONFIRMED,
        )
        .scalar()
    )

    flagged = (
        db.query(func.count(AttendanceAttempt.id))
        .filter(
            AttendanceAttempt.classroom_id == classroom_id,
            AttendanceAttempt.status == AttendanceStatus.FLAGGED,
        )
        .scalar()
    )

    total = (
        db.query(func.count(AttendanceAttempt.id))
        .filter(
            AttendanceAttempt.classroom_id == classroom_id,
        )
        .scalar()
    )

    return {
        "classroom_id": classroom_id,
        "total": total,
        "confirmed": confirmed,
        "flagged": flagged,
    }


@router.get("/flagged-attendance")
def get_flagged_attendance(
    classroom_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    ensure_faculty_owns_classroom(
        db,
        current_user.id,
        classroom_id,
    )

    flagged_records = (
        db.query(AttendanceAttempt)
        .filter(
            AttendanceAttempt.classroom_id == classroom_id,
            AttendanceAttempt.status == AttendanceStatus.FLAGGED,
        )
        .all()
    )

    return flagged_records


@router.get("/student-history")
def get_student_history(
    student_id: int,
    classroom_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):

    ensure_faculty_owns_classroom(
        db,
        current_user.id,
        classroom_id,
    )

    history = (
        db.query(AttendanceAttempt)
        .filter(
            AttendanceAttempt.student_id == student_id,
            AttendanceAttempt.classroom_id == classroom_id,
        )
        .order_by(AttendanceAttempt.id.desc())
        .all()
    )

    return history
