# backend\app\api\v1\attendance.py
from fastapi import APIRouter, Depends, HTTPException
import logging
from sqlalchemy.orm import Session as DBSession
from app.db.session import get_db
from app.core.auth import get_current_user
from app.core.dependencies import require_faculty
from app.core.domain_rules import (
    ensure_student_enrolled,
    ensure_class_active,
    ensure_attendance_open,
    ensure_faculty_owns_classroom,
)
from app.core.errors import ApiError, ErrorCode
from app.models.user import User
from app.models.session import Session
from app.models.attendance import AttendanceAttempt
from app.models.attendance_ble_evidence import AttendanceBleEvidence
from app.schemas.attendance import AttendanceAttemptRequest
from app.services.attendance_flagging import classify_attendance
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
    session = (
        db.query(Session)
        .filter(Session.is_active == True)
        .first()
    )

    if not session:
        return {"status": "no_active_session"}

    logger.info(
        "BLE evidence received",
        extra={"ble": data.ble_evidence},
    )

    status = classify_attendance(data.ble_evidence)

    attendance = AttendanceAttempt(status=status)
    db.add(attendance)
    db.flush()

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
    with db.begin():

        ensure_attendance_open(db, classroom_id)

        if current_user.role != "student":
            raise ApiError(
                ErrorCode.NOT_AUTHORIZED,
                "Only students may join attendance",
                status_code=403,
            )

        ensure_student_enrolled(db, current_user.id, classroom_id)

        faculty_session = (
            db.query(Session)
            .filter(
                Session.classroom_id == classroom_id,
                Session.is_active == True,
            )
            .with_for_update()
            .first()
        )

        if not faculty_session:
            raise ApiError(
                ErrorCode.CLASS_NOT_ACTIVE,
                "No active classroom",
                status_code=404,
            )

        student_session = (
            db.query(Session)
            .filter(
                Session.faculty_id == current_user.id,
                Session.is_active == True,
            )
            .first()
        )

        if not student_session:
            raise ApiError(
                ErrorCode.SESSION_MISSING,
                "Student session missing",
                status_code=403,
            )

        existing = (
            db.query(AttendanceAttempt)
            .filter(
                AttendanceAttempt.student_id == current_user.id,
                AttendanceAttempt.session_id == faculty_session.id,
            )
            .first()
        )

        if existing:
            raise ApiError(
                ErrorCode.DUPLICATE_ATTENDANCE,
                "Attendance already recorded",
                status_code=409,
            )

        attendance = AttendanceAttempt(
            student_id=current_user.id,
            classroom_id=classroom_id,
            session_id=faculty_session.id,
            status="present",
        )

        db.add(attendance)

    return {"status": "present"}


@router.get("/classroom/{classroom_id}", dependencies=[Depends(require_faculty)])
def get_classroom_attendance(
    classroom_id: int,
    db: DBSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    ensure_faculty_owns_classroom(db, current_user.id, classroom_id)

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
    with db.begin():

        ensure_faculty_owns_classroom(db, current_user.id, classroom_id)

        faculty_session = (
            db.query(Session)
            .filter(
                Session.classroom_id == classroom_id,
                Session.is_active == True,
            )
            .with_for_update()
            .first()
        )

        if not faculty_session:
            raise ApiError(
                ErrorCode.CLASS_NOT_ACTIVE,
                "No active classroom",
                status_code=404,
            )

        faculty_session.is_active = False

        db.query(AttendanceAttempt).filter(
            AttendanceAttempt.classroom_id == classroom_id
        ).update({"is_locked": True})

    return {"status": "attendance closed"}


@router.post("/resolve", dependencies=[Depends(require_faculty)])
def resolve_attendance(
    request: FacultyResolutionRequest,
    db: DBSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    attendance = db.query(AttendanceAttempt).filter(
        AttendanceAttempt.id == request.attendance_id
    ).first()

    if not attendance:
        raise HTTPException(status_code=404, detail="Attendance record missing")

    ensure_faculty_owns_classroom(db, current_user.id, attendance.classroom_id)

    if not attendance.is_locked:
        raise ApiError(
            ErrorCode.ATTENDANCE_CLOSED,
            "Attendance must be closed first",
            status_code=403,
        )

    old_status = attendance.status
    attendance.status = request.new_status.value

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
