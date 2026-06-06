from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session as DBSession

from app.db.session import get_db
from app.core.auth import get_current_user
from app.core.domain_rules import (
    ensure_faculty_owns_classroom,
    ensure_faculty_teaches_course,
)
from app.core.errors import ApiError, ErrorCode
from app.core.constants.roles import UserRole
from app.models.attendance_session import AttendanceSession
from app.models.user import User
from app.schemas.session import (
    StartSessionRequest,
    SessionResponse,
    ActiveSessionResponse,
)
from app.services.session_cleanup_service import (
    deactivate_expired_sessions,
)

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

    ensure_faculty_owns_classroom(
        db,
        current_user.id,
        request.classroom_id,
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