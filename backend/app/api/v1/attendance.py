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
    ensure_faculty_owns_classroom,
)
from app.core.errors import ApiError, ErrorCode
from app.core.constants.roles import UserRole
from app.models.user import User
from app.models.attendance_session import AttendanceSession
from app.models.attendance import AttendanceAttempt
from app.models.attendance_ble_evidence import AttendanceBleEvidence
from app.models.attendance_ble_nonce import AttendanceBLENonce
from app.schemas.attendance import (
    AttendanceAttemptRequest,
    AttendanceJoinResponse,
    AttendanceSubmitResponse,
    CloseAttendanceResponse,
)
from app.services.ble_security_service import (
    validate_ble_attendance,
)
from app.services.session_cleanup_service import (
    deactivate_expired_sessions,
)

router = APIRouter(tags=["Attendance"])
logger = logging.getLogger(__name__)


@router.post(
    "/attempt",
    response_model=AttendanceSubmitResponse,
)
def submit_attendance(
    data: AttendanceAttemptRequest,
    db: DBSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    deactivate_expired_sessions(db)

    now = datetime.now(timezone.utc)

    try:
        session_id = int(data.session_id)
    except (TypeError, ValueError):
        raise ApiError(
            ErrorCode.INVALID_SESSION,
            "Invalid attendance session",
            status_code=400,
        )

    session = (
        db.query(AttendanceSession)
        .filter(
            AttendanceSession.id == session_id,
        )
        .with_for_update()
        .first()
    )

    if not session:
        raise ApiError(
            ErrorCode.INVALID_SESSION,
            "Attendance session not found",
            status_code=404,
        )

    if session.closed_at is not None:
        raise ApiError(
            ErrorCode.SESSION_CLOSED,
            "Attendance session is closed",
            status_code=403,
        )

    if session.expires_at <= now:
        raise ApiError(
            ErrorCode.SESSION_EXPIRED,
            "Attendance session expired",
            status_code=403,
        )

    if not session.is_active:
        raise ApiError(
            ErrorCode.SESSION_CLOSED,
            "Attendance session inactive",
            status_code=403,
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

        db.commit()

        db.refresh(attendance)

    except IntegrityError:

        db.rollback()

        raise ApiError(
            ErrorCode.DUPLICATE_ATTENDANCE,
            "Attendance already recorded",
            status_code=409,
        )

    except Exception:

        db.rollback()
        raise

    return {
        "status": "accepted",
        "session_id": session.id,
    }


@router.post(
    "/join",
    response_model=AttendanceJoinResponse,
)
def join_attendance(
    classroom_id: int,
    db: DBSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    if current_user.role != UserRole.STUDENT.value:
        raise ApiError(
            ErrorCode.NOT_AUTHORIZED,
            "Only students may join attendance",
            status_code=403,
        )

    ensure_student_enrolled(db, current_user.id, classroom_id)

    deactivate_expired_sessions(db)

    now = datetime.now(timezone.utc)

    faculty_session = (
        db.query(AttendanceSession)
        .filter(
            AttendanceSession.classroom_id == classroom_id,
            AttendanceSession.is_active == True,
            AttendanceSession.closed_at.is_(None),
            AttendanceSession.expires_at > now,
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


@router.post(
    "/close/{classroom_id}",
    response_model=CloseAttendanceResponse,
    dependencies=[Depends(require_faculty)],
)
def close_attendance(
    classroom_id: int,
    db: DBSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    ensure_faculty_owns_classroom(db, current_user.id, classroom_id)

    deactivate_expired_sessions(db)

    now = datetime.now(timezone.utc)

    faculty_session = (
        db.query(AttendanceSession)
        .filter(
            AttendanceSession.classroom_id == classroom_id,
            AttendanceSession.is_active == True,
            AttendanceSession.closed_at.is_(None),
            AttendanceSession.expires_at > now,
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

    db.commit()

    return {
        "status": "closed",
        "classroom_id": classroom_id,
        "session_id": faculty_session.id,
        "closed_at": faculty_session.closed_at,
    }