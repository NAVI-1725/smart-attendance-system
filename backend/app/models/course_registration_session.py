# backend/app/models/course_registration_session.py

from sqlalchemy import (
    Column,
    Integer,
    ForeignKey,
    Boolean,
    DateTime,
)
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base_class import Base


class CourseRegistrationSession(Base):
    __tablename__ = "course_registration_sessions"

    id = Column(
        Integer,
        primary_key=True,
        index=True,
    )

    course_id = Column(
        Integer,
        ForeignKey("courses.id"),
        nullable=False,
        index=True,
    )

    faculty_id = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=False,
        index=True,
    )

    is_active = Column(
        Boolean,
        default=True,
        nullable=False,
    )

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )

    closed_at = Column(
        DateTime(timezone=True),
        nullable=True,
    )

    course = relationship(
        "Course",
        back_populates="registration_sessions",
    )

    faculty = relationship(
        "User",
        back_populates="registration_sessions",
    )