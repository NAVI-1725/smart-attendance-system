# backend/app/services/ble_security_service.py
import time
from typing import Optional

from sqlalchemy.orm import Session

from app.schemas.attendance import BleEvidence
from app.models.attendance import AttendanceStatus
from app.models.attendance_ble_nonce import AttendanceBLENonce
from app.core.constants.security_constants import (
    MAX_BLE_AGE_MS,
    RSSI_FLAG_THRESHOLD,
    RSSI_REJECT_THRESHOLD,
    MIN_NONCE_LENGTH,
    MIN_ACCEPTABLE_VARIANCE,
    MIN_SAMPLE_COUNT,
    MIN_REQUIRED_BEACONS,
    VALID_PROXIMITIES,
)
from app.exceptions.ble_exceptions import (
    InvalidBLEEvidence,
    ReplayAttackDetected,
)
from app.services.beacon_registry_service import (
    validate_all_beacons,
)
from app.services.beacon_signature_service import (
    validate_all_signatures,
)


def validate_ble_freshness(
    ble: BleEvidence,
) -> AttendanceStatus:

    current_time_ms = int(time.time() * 1000)

    for beacon_id, beacon in ble.per_beacon.items():

        ble_age = current_time_ms - beacon.last_seen_epoch_ms

        if ble_age > MAX_BLE_AGE_MS:
            return AttendanceStatus.FLAGGED

    return AttendanceStatus.CONFIRMED


def validate_nonce_strength(
    ble: BleEvidence,
) -> None:

    for beacon_id, beacon in ble.per_beacon.items():

        if not beacon.nonce:
            raise InvalidBLEEvidence(
                "BLE nonce missing",
            )

        if len(beacon.nonce) < MIN_NONCE_LENGTH:
            raise InvalidBLEEvidence(
                "BLE nonce too short",
            )


def detect_replay_attack(
    db: Session,
    session_id,
    ble: BleEvidence,
) -> None:

    for beacon_id, beacon in ble.per_beacon.items():

        existing_nonce = (
            db.query(AttendanceBLENonce)
            .filter(
                AttendanceBLENonce.session_id == session_id,
                AttendanceBLENonce.nonce == beacon.nonce,
            )
            .first()
        )

        if existing_nonce:
            raise ReplayAttackDetected()


def classify_signal_strength(
    average_rssi: float,
) -> AttendanceStatus:

    if average_rssi <= RSSI_REJECT_THRESHOLD:
        raise InvalidBLEEvidence(
            "BLE signal strength invalid",
        )

    if average_rssi <= RSSI_FLAG_THRESHOLD:
        return AttendanceStatus.FLAGGED

    return AttendanceStatus.CONFIRMED


def validate_beacon_integrity(
    ble: BleEvidence,
) -> AttendanceStatus:

    beacon_count = 0

    for beacon_id, beacon in ble.per_beacon.items():

        beacon_count += 1

        print(
            "VARIANCE =",
            beacon.variance,
        )
        print(
            "MIN VARIANCE =",
            MIN_ACCEPTABLE_VARIANCE,
        )

        print("OVERALL =", ble.overall)
        print("VARIANCE =", beacon.variance)

        if beacon.variance is not None:
            if beacon.variance < MIN_ACCEPTABLE_VARIANCE:
                print(
                    "LOW VARIANCE =",
                    beacon.variance,
                )

        print("OVERALL =", ble.overall)
        print("VARIANCE =", beacon.variance)

        print(
            "SAMPLE COUNT =",
            beacon.sample_count,
        )
        print(
            "MIN SAMPLES =",
            MIN_SAMPLE_COUNT,
        )

        if beacon.sample_count < MIN_SAMPLE_COUNT:
            print(
                "LOW SAMPLE COUNT =",
                beacon.sample_count,
            )

        if beacon.proximity not in VALID_PROXIMITIES:
            return AttendanceStatus.FLAGGED

    print(
        "BEACON COUNT =",
        beacon_count,
    )
    print(
        "MIN REQUIRED =",
        MIN_REQUIRED_BEACONS,
    )

    if beacon_count < MIN_REQUIRED_BEACONS:
        print(
            "BEACON COUNT =",
            beacon_count,
        )
        print(
            "MIN REQUIRED =",
            MIN_REQUIRED_BEACONS,
        )

        return AttendanceStatus.FLAGGED

    return AttendanceStatus.CONFIRMED


def validate_ble_attendance(
    db: Session,
    session_id,
    classroom_id: int,
    ble: Optional[BleEvidence],
) -> AttendanceStatus:

    if ble is None:
        raise InvalidBLEEvidence(
            "BLE evidence missing",
        )

    freshness_status = validate_ble_freshness(ble)

    if freshness_status == AttendanceStatus.FLAGGED:
        return AttendanceStatus.FLAGGED

    validate_nonce_strength(ble)

    validate_all_beacons(
        db=db,
        classroom_id=classroom_id,
        ble=ble,
    )

    validate_all_signatures(
        db=db,
        classroom_id=classroom_id,
        ble=ble,
    )

    # Current implementation performs replay detection
    # before nonce insertion. A future hardening phase
    # should move nonce persistence into this validator
    # and rely on a database UNIQUE constraint as the
    # final replay authority to eliminate concurrency gaps.
    detect_replay_attack(
        db=db,
        session_id=session_id,
        ble=ble,
    )

    for beacon_id, beacon in ble.per_beacon.items():

        signal_status = classify_signal_strength(
            beacon.average_rssi,
        )

        if signal_status == AttendanceStatus.FLAGGED:
            return AttendanceStatus.FLAGGED

    integrity_status = validate_beacon_integrity(ble)

    if integrity_status == AttendanceStatus.FLAGGED:
        return AttendanceStatus.FLAGGED

    print("OVERALL =", ble.overall)
    print("VARIANCE =", beacon.variance)

    if ble.overall not in (
        "IMMEDIATE",
        "NEAR",
        "MEDIUM",
    ):
        return AttendanceStatus.FLAGGED

    print("OVERALL =", ble.overall)
    print("VARIANCE =", beacon.variance)

    return AttendanceStatus.CONFIRMED