# backend\tests\security\test_replay_protection.py
import pytest

from app.models.attendance_ble_nonce import AttendanceBLENonce
from app.exceptions.ble_exceptions import ReplayAttackDetected
from app.services.ble_security_service import validate_ble_attendance


def test_replay_attack_detection(
    db, attendance_session, classroom, signed_ble_evidence
):
    beacon = signed_ble_evidence.per_beacon["AP_BEACON_001"]

    # Insert a nonce that matches the beacon evidence to simulate replay
    nonce = AttendanceBLENonce(
        session_id=attendance_session.id,
        nonce=beacon.nonce,
    )
    db.add(nonce)
    db.commit()

    # Expect replay attack detection to raise the exception
    with pytest.raises(ReplayAttackDetected):
        validate_ble_attendance(
            db=db,
            session_id=attendance_session.id,
            classroom_id=classroom.id,
            ble=signed_ble_evidence,
        )
