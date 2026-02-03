# backend\app\models\attendance.py
from enum import Enum
from sqlalchemy import Column, Integer, String, ForeignKey, Boolean, UniqueConstraint
from sqlalchemy.orm import relationship
from sqlalchemy.types import Enum as SqlEnum
from app.db.base_class import Base


class AttendanceStatus(str, Enum):
    CONFIRMED = "CONFIRMED"
    FLAGGED = "FLAGGED"


class AttendanceAttempt(Base):
    __tablename__ = "attendance"

    __table_args__ = (
        UniqueConstraint("student_id", "session_id"),
    )

    id = Column(Integer, primary_key=True)

    # STEP 2.3 — Attendance Graph Wiring
    student_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    classroom_id = Column(Integer, ForeignKey("classrooms.id"), nullable=False)
    session_id = Column(Integer, ForeignKey("sessions.id"), nullable=False)

    # NOTE:
    # TEMPORARILY downgraded from Postgres ENUM to plain String to unblock Alembic
    # migrations (the `attendance_status` type does not yet exist in DB).
    # Original enum is preserved above for later controlled reintroduction.
    status = Column(
        String,
        nullable=False,
    )

    # STEP 2.6 — Attendance Close + Lock
    is_locked = Column(Boolean, default=False)

    ble_evidence = relationship(
        "AttendanceBleEvidence",
        back_populates="attendance",
        cascade="all, delete-orphan",
    )
