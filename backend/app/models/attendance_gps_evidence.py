# backend/app/models/attendance_gps_evidence.py

from sqlalchemy import (
    Column,
    Integer,
    Float,
    Text,
    ForeignKey,
    DateTime,
    func,
)
from sqlalchemy.orm import relationship
from sqlalchemy.types import Enum as SqlEnum

from app.db.base_class import Base
from app.models.enums import GPSValidationResult


class AttendanceGpsEvidence(Base):
    """
    Immutable GPS evidence snapshot captured during an attendance attempt.

    Raw Evidence:
        - latitude
        - longitude
        - accuracy_meters
        - captured_at

    Evaluation Snapshot:
        - distance_from_classroom_meters
        - validation_result
        - validation_reason

    Notes:
        - One GPS evidence record per AttendanceAttempt.
        - Validation fields are nullable because Part B introduces
          persistence only. Validation logic arrives in later phases.
    """

    __tablename__ = "attendance_gps_evidence"

    id = Column(
        Integer,
        primary_key=True,
    )

    attendance_id = Column(
        Integer,
        ForeignKey(
            "attendance.id",
            ondelete="CASCADE",
        ),
        nullable=False,
        unique=True,
        index=True,
    )

    # ------------------------------------------------------------------
    # Raw GPS Evidence
    # ------------------------------------------------------------------

    latitude = Column(
        Float,
        nullable=False,
    )

    longitude = Column(
        Float,
        nullable=False,
    )

    accuracy_meters = Column(
        Float,
        nullable=False,
    )

    captured_at = Column(
        DateTime(timezone=True),
        nullable=False,
    )

    # ------------------------------------------------------------------
    # Evaluation Snapshot
    # ------------------------------------------------------------------

    distance_from_classroom_meters = Column(
        Float,
        nullable=True,
    )

    validation_result = Column(
        SqlEnum(
            GPSValidationResult,
            name="gps_validation_result",
        ),
        nullable=True,
    )

    validation_reason = Column(
        Text,
        nullable=True,
    )

    # ------------------------------------------------------------------
    # Audit Metadata
    # ------------------------------------------------------------------

    created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )

    # ------------------------------------------------------------------
    # Relationships
    # ------------------------------------------------------------------

    attendance = relationship(
        "AttendanceAttempt",
        back_populates="gps_evidence",
    )