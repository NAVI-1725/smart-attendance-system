# backend/tests/security/test_signature_validation.py
import pytest

from app.exceptions.ble_exceptions import InvalidBLEEvidence
from app.services.ble_security_service import validate_ble_attendance


def test_invalid_signature(db, attendance_session, classroom, signed_ble_evidence):
    beacon = signed_ble_evidence.per_beacon["AP_BEACON_001"]
    beacon.signature = "INVALID_SIGNATURE"

    with pytest.raises(InvalidBLEEvidence):
        validate_ble_attendance(
            db=db,
            session_id=attendance_session.id,
            classroom_id=classroom.id,
            ble=signed_ble_evidence,
        )


def test_modified_nonce_breaks_signature(
    db, attendance_session, classroom, signed_ble_evidence
):
    beacon = signed_ble_evidence.per_beacon["AP_BEACON_001"]
    beacon.nonce = "tampered_nonce"

    with pytest.raises(InvalidBLEEvidence):
        validate_ble_attendance(
            db=db,
            session_id=attendance_session.id,
            classroom_id=classroom.id,
            ble=signed_ble_evidence,
        )


def test_modified_timestamp_breaks_signature(
    db,
    attendance_session,
    classroom,
    signed_ble_evidence,
):

    beacon = signed_ble_evidence.per_beacon["AP_BEACON_001"]

    original_signature = beacon.signature

    original_timestamp = beacon.last_seen_epoch_ms

    beacon.last_seen_epoch_ms = original_timestamp + 5000

    beacon.signature = original_signature

    with pytest.raises(InvalidBLEEvidence):

        validate_ble_attendance(
            db=db,
            session_id=attendance_session.id,
            classroom_id=classroom.id,
            ble=signed_ble_evidence,
        )


def test_modified_classroom_breaks_signature(
    db,
    attendance_session,
    signed_ble_evidence,
):
    with pytest.raises(InvalidBLEEvidence):
        validate_ble_attendance(
            db=db,
            session_id=attendance_session.id,
            classroom_id=999,
            ble=signed_ble_evidence,
        )


def test_inactive_secret_fails_validation(
    db,
    attendance_session,
    classroom,
    beacon_secret,
    signed_ble_evidence,
):
    beacon_secret["secret_1"].is_active = False
    db.commit()

    with pytest.raises(InvalidBLEEvidence):
        validate_ble_attendance(
            db=db,
            session_id=attendance_session.id,
            classroom_id=classroom.id,
            ble=signed_ble_evidence,
        )


def test_wrong_secret_breaks_signature(
    db,
    attendance_session,
    classroom,
    beacon_secret,
    signed_ble_evidence,
):
    beacon_secret["secret_1"].secret_key = "WRONG_SECRET"
    db.commit()

    with pytest.raises(InvalidBLEEvidence):
        validate_ble_attendance(
            db=db,
            session_id=attendance_session.id,
            classroom_id=classroom.id,
            ble=signed_ble_evidence,
        )
