# backend/app/models/attendance_claim.py

from sqlalchemy import (
    Column,
    Integer,
    ForeignKey,
    DateTime,
    Text,
    UniqueConstraint,
)
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from sqlalchemy.types import Enum as SqlEnum

from app.db.base_class import Base
from app.models.enums import (
    AttendanceStatus,
    ClaimStatus,
)


class AttendanceClaim(Base):
    __tablename__ = "attendance_claims"

    __table_args__ = (
        UniqueConstraint(
            "attendance_id",
            name="uq_claim_attendance",
        ),
    )

    id = Column(
        Integer,
        primary_key=True,
    )

    attendance_id = Column(
        Integer,
        ForeignKey("attendance.id"),
        nullable=False,
        index=True,
    )

    student_id = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=False,
        index=True,
    )

    original_attendance_status = Column(
        SqlEnum(
            AttendanceStatus,
            name="attendance_status",
        ),
        nullable=False,
    )

    reason = Column(
        Text,
        nullable=False,
    )

    status = Column(
        SqlEnum(
            ClaimStatus,
            name="claim_status",
        ),
        nullable=False,
        default=ClaimStatus.PENDING,
    )

    claim_resolved_by = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=True,
    )

    claim_resolved_at = Column(
        DateTime(timezone=True),
        nullable=True,
    )

    claim_resolution_reason = Column(
        Text,
        nullable=True,
    )

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )

    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )

    attendance = relationship(
        "AttendanceAttempt",
        foreign_keys=[attendance_id],
    )

    student = relationship(
        "User",
        foreign_keys=[student_id],
    )

    resolver = relationship(
        "User",
        foreign_keys=[claim_resolved_by],
    )