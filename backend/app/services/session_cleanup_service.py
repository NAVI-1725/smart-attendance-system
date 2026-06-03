# backend\app\services\session_cleanup_service.py
from datetime import datetime, timezone

from sqlalchemy.orm import Session

from app.models.attendance_session import AttendanceSession


def deactivate_expired_sessions(db: Session):

    now = datetime.now(timezone.utc)

    expired_sessions = (
        db.query(AttendanceSession)
        .filter(
            AttendanceSession.is_active == True,
            AttendanceSession.closed_at.is_(None),
            AttendanceSession.expires_at <= now,
        )
        .all()
    )

    for session in expired_sessions:
        session.is_active = False
        session.closed_at = now

    if expired_sessions:
        db.commit()