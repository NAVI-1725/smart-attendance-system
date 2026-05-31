# backend/app/services/beacon_registry_service.py
from sqlalchemy.orm import Session

from app.models.trusted_ble_beacon import TrustedBLEBeacon
from app.exceptions.ble_exceptions import InvalidBLEEvidence


def validate_trusted_beacon(
    db: Session,
    beacon_uuid: str,
) -> None:

    beacon = (
        db.query(TrustedBLEBeacon)
        .filter(
            TrustedBLEBeacon.beacon_uuid == beacon_uuid,
            TrustedBLEBeacon.is_active.is_(True),
        )
        .first()
    )

    if not beacon:
        raise InvalidBLEEvidence(
            "Untrusted BLE beacon detected",
        )


def validate_classroom_beacon_access(
    db: Session,
    classroom_id: int,
    beacon_uuid: str,
) -> None:

    beacon = (
        db.query(TrustedBLEBeacon)
        .filter(
            TrustedBLEBeacon.beacon_uuid == beacon_uuid,
            TrustedBLEBeacon.classroom_id == classroom_id,
            TrustedBLEBeacon.is_active.is_(True),
        )
        .first()
    )

    if not beacon:
        raise InvalidBLEEvidence(
            "Beacon not authorized for classroom",
        )


def validate_all_beacons(
    db: Session,
    classroom_id: int,
    ble,
) -> None:

    for _, beacon in ble.per_beacon.items():

        validate_classroom_beacon_access(
            db=db,
            classroom_id=classroom_id,
            beacon_uuid=beacon.beacon_id,
        )
