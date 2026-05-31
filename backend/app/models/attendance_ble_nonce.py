# backend/app/models/attendance_ble_nonce.py

from sqlalchemy import (
    Column,
    Integer,
    String,
    ForeignKey,
    UniqueConstraint,
    DateTime,
)

from sqlalchemy.sql import func

from app.db.base_class import Base


class AttendanceBLENonce(Base):
    __tablename__ = "attendance_ble_nonce_cache"

    __table_args__ = (
        UniqueConstraint(
            "session_id",
            "nonce",
            name="uq_ble_nonce_session",
        ),
    )

    id = Column(Integer, primary_key=True)

    session_id = Column(
        Integer,
        ForeignKey("attendance_sessions.id"),
        nullable=False,
        index=True,
    )

    nonce = Column(
        String,
        nullable=False,
        index=True,
    )

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
    )
