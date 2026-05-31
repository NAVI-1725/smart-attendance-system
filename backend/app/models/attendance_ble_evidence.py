# backend\app\models\attendance_ble_evidence.py
from sqlalchemy import Column, Integer, ForeignKey, JSON, DateTime, func
from sqlalchemy.orm import relationship

# IMPORTANT:
# Import Base from base_class to avoid circular imports with app.db.base
from app.db.base_class import Base


class AttendanceBleEvidence(Base):
    __tablename__ = "attendance_ble_evidence"

    id = Column(Integer, primary_key=True)

    attendance_id = Column(
        Integer,
        ForeignKey("attendance.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    ble_payload = Column(JSON, nullable=False)

    # Future-proof forensic/replay-analysis support fields.
    # Kept nullable to avoid breaking existing flows and migrations.
    device_id = Column(Integer, nullable=True)

    client_timestamp = Column(
        DateTime(timezone=True),
        nullable=True,
    )

    server_received_timestamp = Column(
        DateTime(timezone=True),
        nullable=True,
    )

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
    )

    # Use the REAL model class name
    attendance = relationship(
        "AttendanceAttempt",
        back_populates="ble_evidence",
    )
