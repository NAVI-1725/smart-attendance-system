# backend/tests/security/test_ble_security.py
import pytest

from app.models.attendance import AttendanceStatus
from app.exceptions.ble_exceptions import InvalidBLEEvidence
from app.services.ble_security_service import validate_ble_attendance


def test_valid_ble_attendance(db, attendance_session, classroom, signed_ble_evidence):
    status = validate_ble_attendance(
        db=db,
        session_id=attendance_session.id,
        classroom_id=classroom.id,
        ble=signed_ble_evidence,
    )
    assert status == AttendanceStatus.CONFIRMED


def test_stale_ble_timestamp(db, attendance_session, classroom, signed_ble_evidence):
    beacon = signed_ble_evidence.per_beacon["AP_BEACON_001"]
    beacon.last_seen_epoch_ms = 0

    status = validate_ble_attendance(
        db=db,
        session_id=attendance_session.id,
        classroom_id=classroom.id,
        ble=signed_ble_evidence,
    )
    assert status == AttendanceStatus.FLAGGED


def test_weak_nonce(db, attendance_session, classroom, signed_ble_evidence):
    beacon = signed_ble_evidence.per_beacon["AP_BEACON_001"]
    beacon.nonce = "123"

    with pytest.raises(InvalidBLEEvidence):
        validate_ble_attendance(
            db=db,
            session_id=attendance_session.id,
            classroom_id=classroom.id,
            ble=signed_ble_evidence,
        )
