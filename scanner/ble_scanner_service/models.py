# scanner\ble_scanner_service\models.py

from dataclasses import dataclass


@dataclass
class BeaconPayload:
    beacon_id: str
    nonce: str
    timestamp: int
    signature: str


@dataclass
class RSSIStatistics:
    average_rssi: float
    variance: float
    sample_count: int