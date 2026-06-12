# backend/app/services/session_discovery_service.py

from datetime import datetime, timezone

from sqlalchemy.orm import Session
from sqlalchemy.orm import selectinload

from app.models.attendance_session import AttendanceSession
from app.models.enrollment import Enrollment
from app.models.enums import AttendanceSessionStatus
from app.schemas.session import StudentActiveSessionResponse
from app.services.session_cleanup_service import (
    deactivate_expired_sessions,
)


def build_student_session_response(
    session: AttendanceSession,
) -> StudentActiveSessionResponse:
    return StudentActiveSessionResponse(
        session_id=session.id,
        course_id=session.course.id,
        course_code=session.course.course_code,
        course_name=session.course.course_name,
        faculty_id=session.faculty.id,
        faculty_name=session.faculty.full_name,
        classroom_id=session.classroom.id,
        classroom_name=session.classroom.name,
        started_at=session.started_at,
        expires_at=session.expires_at,
        status=session.status,
    )


def get_active_sessions_for_student(
    db: Session,
    student_id: int,
) -> list[StudentActiveSessionResponse]:

    deactivate_expired_sessions(db)

    course_ids = [
        enrollment.course_id
        for enrollment in (
            db.query(Enrollment)
            .filter(
                Enrollment.student_id == student_id,
            )
            .all()
        )
    ]

    if not course_ids:
        return []

    now = datetime.now(timezone.utc)

    sessions = (
        db.query(AttendanceSession)
        .options(
            selectinload(AttendanceSession.course),
            selectinload(AttendanceSession.faculty),
            selectinload(AttendanceSession.classroom),
        )
        .filter(
            AttendanceSession.course_id.in_(course_ids),
            AttendanceSession.status
            == AttendanceSessionStatus.ACTIVE,
            AttendanceSession.is_active.is_(True),
            AttendanceSession.closed_at.is_(None),
            AttendanceSession.expires_at > now,
        )
        .order_by(
            AttendanceSession.expires_at.asc(),
        )
        .all()
    )

    return [
        build_student_session_response(session)
        for session in sessions
    ]