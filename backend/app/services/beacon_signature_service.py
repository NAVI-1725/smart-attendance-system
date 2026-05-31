# backend\app\services\beacon_signature_service.py
import hashlib
import hmac

from sqlalchemy.orm import Session

from app.models.beacon_secret import BeaconSecret
from app.models.trusted_ble_beacon import TrustedBLEBeacon
from app.schemas.attendance import BleEvidence
from app.exceptions.ble_exceptions import InvalidBLEEvidence


def generate_signature_payload(
    beacon_id: str,
    nonce: str,
    timestamp: int,
    classroom_id: int,
) -> str:

    return f"{beacon_id}|" f"{nonce}|" f"{timestamp}|" f"{classroom_id}"


def verify_beacon_signature(
    db: Session,
    classroom_id: int,
    beacon,
) -> None:

    trusted_beacon = (
        db.query(TrustedBLEBeacon)
        .filter(
            TrustedBLEBeacon.beacon_uuid == beacon.beacon_id,
            TrustedBLEBeacon.classroom_id == classroom_id,
            TrustedBLEBeacon.is_active.is_(True),
        )
        .first()
    )

    if not trusted_beacon:
        raise InvalidBLEEvidence(
            "Beacon authorization failed",
        )

    beacon_secret = (
        db.query(BeaconSecret)
        .filter(
            BeaconSecret.beacon_id == trusted_beacon.id,
            BeaconSecret.is_active.is_(True),
        )
        .first()
    )

    if not beacon_secret:
        raise InvalidBLEEvidence(
            "Beacon secret missing",
        )

    payload = generate_signature_payload(
        beacon_id=beacon.beacon_id,
        nonce=beacon.nonce,
        timestamp=beacon.last_seen_epoch_ms,
        classroom_id=classroom_id,
    )

    expected_signature = hmac.new(
        beacon_secret.secret_key.encode(),
        payload.encode(),
        hashlib.sha256,
    ).hexdigest()

    if not hmac.compare_digest(
        expected_signature,
        beacon.signature,
    ):
        raise InvalidBLEEvidence(
            "Invalid beacon signature",
        )


def validate_all_signatures(
    db: Session,
    classroom_id: int,
    ble: BleEvidence,
) -> None:

    for _, beacon in ble.per_beacon.items():

        verify_beacon_signature(
            db=db,
            classroom_id=classroom_id,
            beacon=beacon,
        )
