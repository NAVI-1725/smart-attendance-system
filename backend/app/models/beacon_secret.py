# backend/app/models/beacon_secret.py

from sqlalchemy import (
    Column,
    Integer,
    String,
    Boolean,
    ForeignKey,
    DateTime,
)

from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from app.db.base_class import Base


class BeaconSecret(Base):
    __tablename__ = "beacon_secrets"

    id = Column(Integer, primary_key=True)

    beacon_id = Column(
        Integer,
        ForeignKey("trusted_ble_beacons.id"),
        nullable=False,
        index=True,
    )

    secret_key = Column(
        String,
        nullable=False,
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

    beacon = relationship(
        "TrustedBLEBeacon",
        back_populates="beacon_secrets",
    )