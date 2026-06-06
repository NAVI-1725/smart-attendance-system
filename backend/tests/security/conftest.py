# backend\tests\security\conftest.py
import hashlib
import hmac
import time
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parents[2]

if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.db.base import Base
from app.models.user import User
from app.models.course import Course
from app.models.classroom import Classroom
from app.models.attendance_session import AttendanceSession
from app.models.trusted_ble_beacon import TrustedBLEBeacon
from app.models.beacon_secret import BeaconSecret
from app.schemas.attendance import (
    BeaconEvidence,
    BleEvidence,
)

# Database setup
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"
engine = create_engine(SQLALCHEMY_DATABASE_URL)

TestingSessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
)


# Fixtures
@pytest.fixture(scope="function")
def db():
    Base.metadata.create_all(bind=engine)
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()
        Base.metadata.drop_all(bind=engine)


@pytest.fixture()
def faculty_user(db):
    faculty = User(
        email="faculty@test.com",
        password_hash="hashed",
        full_name="Faculty",
        role="faculty",
    )
    db.add(faculty)
    db.commit()
    db.refresh(faculty)
    return faculty


@pytest.fixture()
def student_user(db):
    student = User(
        email="student@test.com",
        password_hash="hashed",
        full_name="Student",
        role="student",
    )
    db.add(student)
    db.commit()
    db.refresh(student)
    return student


@pytest.fixture()
def course(db):
    course = Course(
        course_code="CSE101",
        course_name="Computer Science",
    )

    db.add(course)
    db.commit()
    db.refresh(course)

    return course


@pytest.fixture()
def classroom(db, faculty_user):
    classroom = Classroom(
        name="AP Classroom",
        faculty_id=faculty_user.id,
        latitude=16.5062,
        longitude=80.6480,
        gps_radius_meters=50,
    )
    db.add(classroom)
    db.commit()
    db.refresh(classroom)
    return classroom


@pytest.fixture()
def attendance_session(
    db,
    faculty_user,
    classroom,
    course,
):
    session = AttendanceSession(
        faculty_id=faculty_user.id,
        course_id=course.id,
        classroom_id=classroom.id,
        is_active=True,
        expires_at=datetime.now(timezone.utc)
        + timedelta(minutes=30),
    )

    db.add(session)
    db.commit()
    db.refresh(session)

    return session


@pytest.fixture()
def trusted_beacon(
    db,
    classroom,
):

    beacon_1 = TrustedBLEBeacon(
        classroom_id=classroom.id,
        beacon_uuid="AP_BEACON_001",
        beacon_name="Main Beacon",
        is_active=True,
    )

    beacon_2 = TrustedBLEBeacon(
        classroom_id=classroom.id,
        beacon_uuid="AP_BEACON_002",
        beacon_name="Secondary Beacon",
        is_active=True,
    )

    db.add(beacon_1)
    db.add(beacon_2)

    db.commit()

    db.refresh(beacon_1)
    db.refresh(beacon_2)

    return {
        "beacon_1": beacon_1,
        "beacon_2": beacon_2,
    }


@pytest.fixture()
def beacon_secret(
    db,
    trusted_beacon,
):

    secret_1 = BeaconSecret(
        beacon_id=trusted_beacon["beacon_1"].id,
        secret_key="SUPER_SECRET_KEY_1",
        is_active=True,
    )

    secret_2 = BeaconSecret(
        beacon_id=trusted_beacon["beacon_2"].id,
        secret_key="SUPER_SECRET_KEY_2",
        is_active=True,
    )

    db.add(secret_1)
    db.add(secret_2)

    db.commit()

    db.refresh(secret_1)
    db.refresh(secret_2)

    return {
        "secret_1": secret_1,
        "secret_2": secret_2,
    }


@pytest.fixture()
def signed_ble_evidence(classroom, beacon_secret):
    nonce = "nonce123456"
    timestamp = int(time.time() * 1000)

    payload = f"AP_BEACON_001|{nonce}|{timestamp}|{classroom.id}"

    signature = hmac.new(
        beacon_secret["secret_1"].secret_key.encode(),
        payload.encode(),
        hashlib.sha256,
    ).hexdigest()

    beacon = BeaconEvidence(
        beacon_id="AP_BEACON_001",
        average_rssi=-60,
        variance=5,
        sample_count=5,
        proximity="NEAR",
        last_seen_epoch_ms=timestamp,
        nonce=nonce,
        signature=signature,
    )

    payload_2 = (
        f"AP_BEACON_002|"
        f"{nonce}|"
        f"{timestamp}|"
        f"{classroom.id}"
    )

    signature_2 = hmac.new(
        beacon_secret["secret_2"].secret_key.encode(),
        payload_2.encode(),
        hashlib.sha256,
    ).hexdigest()

    beacon_2 = BeaconEvidence(
        beacon_id="AP_BEACON_002",
        average_rssi=-60,
        variance=5,
        sample_count=5,
        proximity="NEAR",
        last_seen_epoch_ms=timestamp,
        nonce=nonce,
        signature=signature_2,
    )

    return BleEvidence(
        overall="STRONG",
        per_beacon={
            "AP_BEACON_001": beacon,
            "AP_BEACON_002": beacon_2,
        },
    )