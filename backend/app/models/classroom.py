# backend/app/models/classroom.py

from sqlalchemy import (
    Column,
    Integer,
    String,
    ForeignKey,
    DateTime,
    CheckConstraint,
    Numeric,
)
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from app.db.base_class import Base


class Classroom(Base):
    __tablename__ = "classrooms"

    __table_args__ = (
        CheckConstraint(
            "latitude >= -90 AND latitude <= 90",
            name="ck_classroom_latitude_range",
        ),
        CheckConstraint(
            "longitude >= -180 AND longitude <= 180",
            name="ck_classroom_longitude_range",
        ),
        CheckConstraint(
            "gps_radius_meters > 0",
            name="ck_classroom_gps_radius_positive",
        ),
    )

    id = Column(Integer, primary_key=True, index=True)

    name = Column(String, nullable=False)

    faculty_id = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=False,
    )

    latitude = Column(
        Numeric(10, 7),
        nullable=False,
    )

    longitude = Column(
        Numeric(10, 7),
        nullable=False,
    )

    gps_radius_meters = Column(
        Integer,
        nullable=False,
    )

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
    )

    attendance_sessions = relationship(
        "AttendanceSession",
        back_populates="classroom",
        cascade="all, delete-orphan",
    )

    trusted_ble_beacons = relationship(
        "TrustedBLEBeacon",
        back_populates="classroom",
        cascade="all, delete-orphan",
    )