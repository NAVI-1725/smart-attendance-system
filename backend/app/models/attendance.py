# backend/app/models/attendance.py
from enum import Enum

from sqlalchemy import Column, Integer
from sqlalchemy.orm import relationship
from app.db.base_class import Base


class AttendanceStatus(str, Enum):
    CONFIRMED = "CONFIRMED"
    FLAGGED = "FLAGGED"


class AttendanceAttempt(Base):
    __tablename__ = "attendance"

    id = Column(Integer, primary_key=True)

    ble_evidence = relationship(
        "AttendanceBleEvidence",
        back_populates="attendance",
        cascade="all, delete-orphan",
    )
