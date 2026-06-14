# backend/app/models/attendance.py

from sqlalchemy import (
    Column,
    Integer,
    ForeignKey,
    UniqueConstraint,
    DateTime,
    Text,
)
from sqlalchemy.orm import relationship
from sqlalchemy.types import Enum as SqlEnum

from app.db.base_class import Base
from app.models.enums import AttendanceStatus


class AttendanceAttempt(Base):
    __tablename__ = "attendance"

    __table_args__ = (UniqueConstraint("student_id", "session_id"),)

    id = Column(Integer, primary_key=True)

    # STEP 2.3 — Attendance Graph Wiring
    student_id = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=False,
        index=True,
    )

    classroom_id = Column(
        Integer,
        ForeignKey("classrooms.id"),
        nullable=False,
        index=True,
    )

    session_id = Column(
        Integer,
        ForeignKey("attendance_sessions.id"),
        nullable=False,
        index=True,
    )

    # STEP 3.1 — Attendance Status ENUM Enforcement
    status = Column(
        SqlEnum(
            AttendanceStatus,
            name="attendance_status",
        ),
        nullable=False,
    )

    reviewed_by = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=True,
    )

    reviewed_at = Column(
        DateTime(timezone=True),
        nullable=True,
    )

    resolution_reason = Column(
        Text,
        nullable=True,
    )

    ble_evidence = relationship(
        "AttendanceBleEvidence",
        back_populates="attendance",
        cascade="all, delete-orphan",
    )

    gps_evidence = relationship(
        "AttendanceGpsEvidence",
        back_populates="attendance",
        cascade="all, delete-orphan",
        uselist=False,
    )