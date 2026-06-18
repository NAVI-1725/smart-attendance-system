# backend/app/models/course.py

from sqlalchemy import (
    Column,
    Integer,
    String,
    DateTime,
    UniqueConstraint,
    Index,
)
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from app.db.base_class import Base


class Course(Base):
    __tablename__ = "courses"

    __table_args__ = (
        UniqueConstraint(
            "course_code",
            name="uq_course_code",
        ),
        Index(
            "ix_course_code",
            "course_code",
        ),
    )

    id = Column(
        Integer,
        primary_key=True,
        index=True,
    )

    course_code = Column(
        String(50),
        nullable=False,
    )

    course_name = Column(
        String(255),
        nullable=False,
    )

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )

    # Relationships

    faculty_assignments = relationship(
        "FacultyCourse",
        back_populates="course",
        cascade="all, delete-orphan",
    )

    enrollments = relationship(
        "Enrollment",
        back_populates="course",
        cascade="all, delete-orphan",
    )

    attendance_sessions = relationship(
        "AttendanceSession",
        back_populates="course",
        cascade="all, delete-orphan",
    )

    registration_sessions = relationship(
        "CourseRegistrationSession",
        back_populates="course",
        cascade="all, delete-orphan",
    )