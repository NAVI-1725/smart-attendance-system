# scanner/ble_scanner_service/parser.py

import json

from .models import BeaconPayload


def parse_characteristic_json(payload: str) -> BeaconPayload:
    data = json.loads(payload)

    return BeaconPayload(
        beacon_id=data["beacon_id"],
        nonce=data["nonce"],
        timestamp=int(data["timestamp"]),
        signature=data["signature"],
    )


def build_beacon_evidence(
    beacon_payload: BeaconPayload,
    average_rssi: float,
    variance: float,
    sample_count: int
) -> dict:
    return {
        "beacon_id": beacon_payload.beacon_id,
        "average_rssi": average_rssi,
        "variance": variance,
        "sample_count": sample_count,
        "proximity": "NEAR",
        "last_seen_epoch_ms": beacon_payload.timestamp,
        "nonce": beacon_payload.nonce,
        "signature": beacon_payload.signature,
        "scan_window": 5,
    }


def build_ble_evidence(
    beacon_evidences: list
) -> dict:
    return {
        "overall": "STRONG",
        "per_beacon": {
            beacon_evidence["beacon_id"]: beacon_evidence
            for beacon_evidence in beacon_evidences
        },
    }