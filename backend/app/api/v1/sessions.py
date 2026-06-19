################################################################################
# FILE: backend/app/api/v1/sessions.py
################################################################################

from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends
from sqlalchemy import func
from sqlalchemy.orm import Session as DBSession

from app.db.session import get_db
from app.core.auth import get_current_user
from app.core.domain_rules import (
    ensure_faculty_teaches_course,
    ensure_faculty_owns_session,
)
from app.core.errors import ApiError, ErrorCode
from app.core.constants.roles import UserRole
from app.models.attendance import AttendanceAttempt
from app.models.attendance_session import AttendanceSession
from app.models.enums import (
    AttendanceSessionStatus,
    AttendanceStatus,
)
from app.models.user import User
from app.schemas.session import (
    StartSessionRequest,
    SessionResponse,
    ActiveSessionResponse,
    StudentActiveSessionResponse,
    SessionAttendanceResponse,
)
from app.services.session_cleanup_service import deactivate_expired_sessions
from app.services.session_discovery_service import get_active_sessions_for_student

router = APIRouter(tags=["Sessions"])


@router.post(
    "/start",
    response_model=SessionResponse,
)
def start_session(
    request: StartSessionRequest,
    db: DBSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role != UserRole.FACULTY.value:
        raise ApiError(
            ErrorCode.NOT_AUTHORIZED,
            "Only faculty can start sessions",
            status_code=403,
        )

    ensure_faculty_teaches_course(
        db,
        current_user.id,
        request.course_id,
    )

    deactivate_expired_sessions(db)

    now = datetime.now(timezone.utc)

    existing_session = (
        db.query(AttendanceSession)
        .filter(
            AttendanceSession.classroom_id == request.classroom_id,
            AttendanceSession.is_active == True,
            AttendanceSession.closed_at.is_(None),
            AttendanceSession.expires_at > now,
        )
        .first()
    )

    if existing_session:
        raise ApiError(
            ErrorCode.SESSION_ALREADY_ACTIVE,
            "An active session already exists for this classroom",
            status_code=409,
        )

    expires_at = now + timedelta(minutes=request.duration_minutes)

    session = AttendanceSession(
        faculty_id=current_user.id,
        course_id=request.course_id,
        classroom_id=request.classroom_id,
        is_active=True,
        started_at=now,
        expires_at=expires_at,
        duration_minutes=request.duration_minutes,
    )

    db.add(session)
    db.commit()
    db.refresh(session)

    return {
        "session_id": session.id,
        "expires_at": session.expires_at,
        "duration_minutes": session.duration_minutes,
    }


@router.post(
    "/{session_id}/close",
)
def close_session(
    session_id: int,
    db: DBSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role != UserRole.FACULTY.value:
        raise ApiError(
            ErrorCode.NOT_AUTHORIZED,
            "Only faculty can close sessions",
            status_code=403,
        )

    deactivate_expired_sessions(db)

    session = ensure_faculty_owns_session(
        db=db,
        faculty_id=current_user.id,
        session_id=session_id,
    )

    if session.status == AttendanceSessionStatus.CLOSED:
        raise ApiError(
            ErrorCode.SESSION_CLOSED,
            "Session already closed",
            status_code=409,
        )

    if session.status == AttendanceSessionStatus.EXPIRED:
        raise ApiError(
            ErrorCode.INVALID_SESSION,
            "Session already expired",
            status_code=409,
        )

    now = datetime.now(timezone.utc)

    session.status = AttendanceSessionStatus.CLOSED
    session.is_active = False
    session.closed_at = now

    db.commit()

    return {
        "status": "closed",
        "session_id": session.id,
    }


@router.delete(
    "/{session_id}",
)
def delete_session(
    session_id: int,
    db: DBSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role != UserRole.FACULTY.value:
        raise ApiError(
            ErrorCode.NOT_AUTHORIZED,
            "Only faculty can delete sessions",
            status_code=403,
        )

    deactivate_expired_sessions(db)

    session = ensure_faculty_owns_session(
        db=db,
        faculty_id=current_user.id,
        session_id=session_id,
    )

    attendance_count = (
        db.query(func.count(AttendanceAttempt.id))
        .filter(
            AttendanceAttempt.session_id == session.id,
        )
        .scalar()
    )

    if attendance_count > 0:
        raise ApiError(
            ErrorCode.INVALID_SESSION,
            "Cannot delete a session that has attendance records",
            status_code=409,
        )

    db.delete(session)
    db.commit()

    return {
        "status": "deleted",
        "session_id": session_id,
    }


@router.get(
    "/{session_id}/attendance",
    response_model=SessionAttendanceResponse,
)
def get_session_attendance(
    session_id: int,
    db: DBSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role != UserRole.FACULTY.value:
        raise ApiError(
            ErrorCode.NOT_AUTHORIZED,
            "Only faculty can view session attendance",
            status_code=403,
        )

    deactivate_expired_sessions(db)

    session = ensure_faculty_owns_session(
        db=db,
        faculty_id=current_user.id,
        session_id=session_id,
    )

    records = (
        db.query(AttendanceAttempt)
        .filter(
            AttendanceAttempt.session_id == session.id,
        )
        .all()
    )

    confirmed = sum(
        1
        for record in records
        if record.status == AttendanceStatus.CONFIRMED
    )

    flagged = sum(
        1
        for record in records
        if record.status == AttendanceStatus.FLAGGED
    )

    rejected = sum(
        1
        for record in records
        if record.status == AttendanceStatus.REJECTED
    )

    return {
        "confirmed": confirmed,
        "flagged": flagged,
        "rejected": rejected,
        "records": [
            {
                "attendance_id": record.id,
                "student_id": record.student_id,
                "status": record.status,
            }
            for record in records
        ],
    }


@router.get(
    "/active/{classroom_id}",
    response_model=ActiveSessionResponse | None,
)
def get_active_session(
    classroom_id: int,
    db: DBSession = Depends(get_db),
):
    deactivate_expired_sessions(db)

    now = datetime.now(timezone.utc)

    session = (
        db.query(AttendanceSession)
        .filter(
            AttendanceSession.classroom_id == classroom_id,
            AttendanceSession.is_active == True,
            AttendanceSession.closed_at.is_(None),
            AttendanceSession.expires_at > now,
        )
        .first()
    )

    if not session:
        return None

    return {
        "session_id": session.id,
        "course_id": session.course_id,
        "classroom_id": session.classroom_id,
        "expires_at": session.expires_at,
        "duration_minutes": session.duration_minutes,
    }


@router.get(
    "/my-active-sessions",
    response_model=list[StudentActiveSessionResponse],
)
def get_my_active_sessions(
    db: DBSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role != UserRole.STUDENT.value:
        raise ApiError(
            ErrorCode.NOT_AUTHORIZED,
            "Only students can access active sessions",
            status_code=403,
        )

    return get_active_sessions_for_student(
        db=db,
        student_id=current_user.id,
    )

################################################################################
# END FILE: backend/app/api/v1/sessions.py
################################################################################