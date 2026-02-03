# backend\app\api\v1\attendance.py
from fastapi import APIRouter, Depends, HTTPException
import logging
from sqlalchemy.orm import Session as DBSession
from app.db.session import get_db
from app.core.auth import get_current_user
from app.core.dependencies import require_faculty
from app.models.user import User
from app.models.session import Session
from app.models.attendance import AttendanceAttempt
from app.models.attendance_ble_evidence import AttendanceBleEvidence
from app.schemas.attendance import AttendanceAttemptRequest
from app.services.attendance_flagging import classify_attendance
from app.models.enrollment import Enrollment
from app.models.classroom import Classroom
from app.models.faculty_action_logs import FacultyActionLog
from app.schemas.faculty_resolution import FacultyResolutionRequest

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


@router.post("/join")
def join_attendance(
    classroom_id: int,
    db: DBSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    # STEP 2.6 — Prevent join if attendance locked
    locked = (
        db.query(AttendanceAttempt)
        .filter(
            AttendanceAttempt.classroom_id == classroom_id,
            AttendanceAttempt.is_locked == True,
        )
        .first()
    )

    if locked:
        raise HTTPException(status_code=403, detail="Attendance closed")

    # Only students may join
    if current_user.role != "student":
        raise HTTPException(status_code=403, detail="Only students may join attendance")

    # Must be enrolled
    enrollment = (
        db.query(Enrollment)
        .filter(
            Enrollment.student_id == current_user.id,
            Enrollment.classroom_id == classroom_id,
        )
        .first()
    )

    if not enrollment:
        raise HTTPException(status_code=403, detail="Student not enrolled")

    # Active faculty session for classroom
    faculty_session = (
        db.query(Session)
        .filter(
            Session.classroom_id == classroom_id,
            Session.is_active == True,
        )
        .first()
    )

    if not faculty_session:
        raise HTTPException(status_code=404, detail="No active class session")

    # Student must also have active session
    # NOTE: Session model currently uses faculty_id; reused here to avoid schema changes.
    student_session = (
        db.query(Session)
        .filter(
            Session.faculty_id == current_user.id,
            Session.is_active == True,
        )
        .first()
    )

    if not student_session:
        raise HTTPException(status_code=403, detail="Student session missing")

    # Prevent duplicate attendance
    existing = (
        db.query(AttendanceAttempt)
        .filter(
            AttendanceAttempt.student_id == current_user.id,
            AttendanceAttempt.session_id == faculty_session.id,
        )
        .first()
    )

    if existing:
        return {"status": "already_marked"}

    attendance = AttendanceAttempt(
        student_id=current_user.id,
        classroom_id=classroom_id,
        session_id=faculty_session.id,
        status="present",
    )

    db.add(attendance)
    db.commit()

    return {"status": "present"}


@router.get("/classroom/{classroom_id}", dependencies=[Depends(require_faculty)])
def get_classroom_attendance(
    classroom_id: int,
    db: DBSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    # Verify classroom ownership
    classroom = (
        db.query(Classroom)
        .filter(
            Classroom.id == classroom_id,
            Classroom.faculty_id == current_user.id,
        )
        .first()
    )

    if not classroom:
        raise HTTPException(status_code=404, detail="Classroom not found")

    records = (
        db.query(AttendanceAttempt, User.full_name, User.email)
        .join(User, AttendanceAttempt.student_id == User.id)
        .filter(AttendanceAttempt.classroom_id == classroom_id)
        .all()
    )

    return [
        {
            "student_name": name,
            "student_email": email,
            "status": attendance.status,
        }
        for attendance, name, email in records
    ]


@router.post("/close/{classroom_id}", dependencies=[Depends(require_faculty)])
def close_attendance(
    classroom_id: int,
    db: DBSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    # Verify ownership
    classroom = (
        db.query(Classroom)
        .filter(
            Classroom.id == classroom_id,
            Classroom.faculty_id == current_user.id,
        )
        .first()
    )

    if not classroom:
        raise HTTPException(status_code=404, detail="Classroom not found")

    # Find active session
    faculty_session = (
        db.query(Session)
        .filter(
            Session.classroom_id == classroom_id,
            Session.is_active == True,
        )
        .first()
    )

    if not faculty_session:
        raise HTTPException(status_code=404, detail="No active session")

    # Close session
    faculty_session.is_active = False

    # Lock all attendance rows
    db.query(AttendanceAttempt).filter(
        AttendanceAttempt.classroom_id == classroom_id
    ).update({"is_locked": True})

    db.commit()

    return {"status": "attendance closed"}


@router.post("/resolve", dependencies=[Depends(require_faculty)])
def resolve_attendance(
    request: FacultyResolutionRequest,
    db: DBSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    # Locate attendance row
    attendance = db.query(AttendanceAttempt).filter(
        AttendanceAttempt.id == request.attendance_id
    ).first()

    if not attendance:
        raise HTTPException(status_code=404, detail="Attendance record missing")

    # Verify classroom ownership via attendance.classroom_id
    classroom = db.query(Classroom).filter(
        Classroom.id == attendance.classroom_id,
        Classroom.faculty_id == current_user.id,
    ).first()

    if not classroom:
        raise HTTPException(status_code=404, detail="Classroom not found")

    # Must be locked before manual resolution
    if not attendance.is_locked:
        raise HTTPException(status_code=403, detail="Attendance must be closed first")

    old_status = attendance.status
    attendance.status = request.new_status.value

    # Audit log (immutable trail)
    log = FacultyActionLog(
        faculty_id=current_user.id,
        attendance_id=attendance.id,
        original_status=old_status,
        new_status=request.new_status.value,
        reason=request.reason,
    )

    db.add(log)
    db.commit()

    return {"status": "updated"}
