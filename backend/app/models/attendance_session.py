# attendance_session.py

from sqlalchemy import (
    Column,
    Integer,
    Boolean,
    DateTime,
    ForeignKey,
)
from sqlalchemy.sql import func

from app.db.base_class import Base


class AttendanceSession(Base):
    __tablename__ = "attendance_sessions"

    id = Column(Integer, primary_key=True)

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

    is_active = Column(Boolean, default=True)

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
    )

    closed_at = Column(
        DateTime(timezone=True),
        nullable=True,
    )
