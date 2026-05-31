# backend\app\models\trusted_ble_beacon.py
from sqlalchemy import (
    Column,
    Integer,
    String,
    Boolean,
    ForeignKey,
    DateTime,
)

from sqlalchemy.sql import func

from app.db.base_class import Base


class TrustedBLEBeacon(Base):
    __tablename__ = "trusted_ble_beacons"

    id = Column(Integer, primary_key=True)

    classroom_id = Column(
        Integer,
        ForeignKey("classrooms.id"),
        nullable=False,
        index=True,
    )

    beacon_uuid = Column(
        String,
        nullable=False,
        unique=True,
        index=True,
    )

    beacon_name = Column(
        String,
        nullable=True,
    )

    is_active = Column(
        Boolean,
        default=True,
        nullable=False,
    )

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
    )
