# backend/app/api/v1/attendance.py

from datetime import datetime, timezone

from fastapi import APIRouter, Depends
import logging
from sqlalchemy.orm import Session as DBSession
from sqlalchemy.exc import IntegrityError

from app.db.session import get_db
from app.core.auth import get_current_user
from app.core.dependencies import require_faculty
from app.core.domain_rules import (
    ensure_student_enrolled,
    ensure_attendance_open,
    ensure_faculty_owns_classroom,
)
from app.core.errors import ApiError, ErrorCode
from app.models.user import User
from app.models.attendance_session import AttendanceSession
from app.models.attendance import AttendanceAttempt
from app.models.attendance_ble_evidence import AttendanceBleEvidence
from app.models.attendance_ble_nonce import AttendanceBLENonce
from app.schemas.attendance import AttendanceAttemptRequest
from app.services.ble_security_service import (
    validate_ble_attendance,
)

router = APIRouter(tags=["Attendance"])
logger = logging.getLogger(__name__)


@router.post("/attempt")
def submit_attendance(
    data: AttendanceAttemptRequest,
    db: DBSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    session = (
        db.query(AttendanceSession)
        .filter(
            AttendanceSession.is_active ,
        )
        .with_for_update()
        .first()
    )

    if not session:
        raise ApiError(
            ErrorCode.CLASS_NOT_ACTIVE,
            "No active classroom",
            status_code=404,
        )

    # Validate client-provided session_id against active session
    # to prevent inconsistent or spoofed attendance submissions.
    try:
        session_id = int(data.session_id)
    except (TypeError, ValueError):
        raise ApiError(
            ErrorCode.SESSION_MISSING,
            "Invalid attendance session",
            status_code=400,
        )

    if session_id != session.id:
        raise ApiError(
            ErrorCode.SESSION_MISSING,
            "Invalid attendance session",
            status_code=400,
        )

    if not session.is_active:
        raise ApiError(
            ErrorCode.CLASS_NOT_ACTIVE,
            "Attendance session closed",
            status_code=400,
        )

    logger.info(
        "BLE evidence received",
        extra={"ble": data.ble_evidence},
    )

    status = validate_ble_attendance(
        db=db,
        session_id=session.id,
        classroom_id=session.classroom_id,
        ble=data.ble_evidence,
    )

    try:
        with db.begin():

            attendance = AttendanceAttempt(
                student_id=current_user.id,
                classroom_id=session.classroom_id,
                session_id=session.id,
                status=status,
            )

            db.add(attendance)
            db.flush()

            for _, beacon in data.ble_evidence.per_beacon.items():

                nonce_record = AttendanceBLENonce(
                    session_id=session.id,
                    nonce=beacon.nonce,
                )

                db.add(nonce_record)

            if data.ble_evidence is not None:
                ble_row = AttendanceBleEvidence(
                    attendance_id=attendance.id,
                    ble_payload=data.ble_evidence.dict(),
                )

                db.add(ble_row)

        db.refresh(attendance)

    except IntegrityError:
        db.rollback()

        raise ApiError(
            ErrorCode.DUPLICATE_ATTENDANCE,
            "Attendance already recorded",
            status_code=409,
        )

    return {
        "status": "accepted",
        "session_id": session.id,
    }


@router.post("/join")
def join_attendance(
    classroom_id: int,
    db: DBSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    ensure_attendance_open(db, classroom_id)

    if current_user.role != "student":
        raise ApiError(
            ErrorCode.NOT_AUTHORIZED,
            "Only students may join attendance",
            status_code=403,
        )

    ensure_student_enrolled(db, current_user.id, classroom_id)

    faculty_session = (
        db.query(AttendanceSession)
        .filter(
            AttendanceSession.classroom_id == classroom_id,
            AttendanceSession.is_active ,
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

    # Student authentication is already validated via JWT + get_current_user

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
        status="CONFIRMED",
    )

    db.add(attendance)

    try:
        db.commit()
    except IntegrityError:
        db.rollback()

        raise ApiError(
            ErrorCode.DUPLICATE_ATTENDANCE,
            "Attendance already recorded",
            status_code=409,
        )

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

    ensure_faculty_owns_classroom(db, current_user.id, classroom_id)

    faculty_session = (
        db.query(AttendanceSession)
        .filter(
            AttendanceSession.classroom_id == classroom_id,
            AttendanceSession.is_active ,
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
    faculty_session.closed_at = datetime.now(timezone.utc)

    db.query(AttendanceAttempt).filter(
        AttendanceAttempt.classroom_id == classroom_id
    ).update({"is_locked": True})

    db.commit()

    return {"status": "attendance closed"}
