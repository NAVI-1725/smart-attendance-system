# backend/app/models/attendance_session.py

from sqlalchemy import (
    Column,
    Integer,
    Boolean,
    DateTime,
    ForeignKey,
    Index,
)
from sqlalchemy.sql import func

from app.db.base_class import Base


class AttendanceSession(Base):
    __tablename__ = "attendance_sessions"

    __table_args__ = (
        Index("ix_attendance_sessions_classroom_id", "classroom_id"),
        Index("ix_attendance_sessions_faculty_id", "faculty_id"),
        Index("ix_attendance_sessions_expires_at", "expires_at"),
        Index("ix_attendance_sessions_is_active", "is_active"),
    )

    id = Column(Integer, primary_key=True, index=True)

    faculty_id = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=False,
    )

    classroom_id = Column(
        Integer,
        ForeignKey("classrooms.id"),
        nullable=False,
    )

    is_active = Column(
        Boolean,
        default=True,
        nullable=False,
    )

    started_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
    )

    expires_at = Column(
        DateTime(timezone=True),
        nullable=False,
    )

    duration_minutes = Column(
        Integer,
        nullable=False,
        default=10,
    )

    closed_at = Column(
        DateTime(timezone=True),
        nullable=True,
    )