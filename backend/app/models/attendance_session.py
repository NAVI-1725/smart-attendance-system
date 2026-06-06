# backend/app/models/attendance_session.py

from sqlalchemy import (
    Column,
    Integer,
    Boolean,
    DateTime,
    ForeignKey,
    Index,
)
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from sqlalchemy.types import Enum as SqlEnum

from app.db.base_class import Base
from app.models.enums import AttendanceSessionStatus


class AttendanceSession(Base):
    __tablename__ = "attendance_sessions"

    __table_args__ = (
        Index("ix_attendance_sessions_classroom_id", "classroom_id"),
        Index("ix_attendance_sessions_faculty_id", "faculty_id"),
        Index("ix_attendance_sessions_course_id", "course_id"),
        Index("ix_attendance_sessions_expires_at", "expires_at"),
        Index("ix_attendance_sessions_is_active", "is_active"),
    )

    id = Column(Integer, primary_key=True, index=True)

    faculty_id = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=False,
    )

    course_id = Column(
        Integer,
        ForeignKey("courses.id"),
        nullable=False,
    )

    classroom_id = Column(
        Integer,
        ForeignKey("classrooms.id"),
        nullable=False,
    )

    status = Column(
        SqlEnum(
            AttendanceSessionStatus,
            name="attendance_session_status",
        ),
        nullable=False,
        default=AttendanceSessionStatus.ACTIVE,
        server_default=AttendanceSessionStatus.ACTIVE.value,
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

    course = relationship(
        "Course",
        back_populates="attendance_sessions",
    )

    faculty = relationship(
        "User",
        back_populates="attendance_sessions",
    )

    classroom = relationship(
        "Classroom",
    )