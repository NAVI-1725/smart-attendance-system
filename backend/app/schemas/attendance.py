# backend/app/schemas/attendance.py

from datetime import datetime
from typing import Dict
from pydantic import BaseModel


class BeaconEvidence(BaseModel):
    beacon_id: str

    average_rssi: float
    variance: float
    sample_count: int

    proximity: str

    last_seen_epoch_ms: int

    # Replay protection + future trust scoring support
    nonce: str
    signature: str
    scan_window: int = 5


class BleEvidence(BaseModel):
    overall: str
    per_beacon: Dict[str, BeaconEvidence]


class AttendanceAttemptRequest(BaseModel):
    session_id: str
    ble_evidence: BleEvidence


class AttendanceJoinResponse(BaseModel):
    status: str


class AttendanceSubmitResponse(BaseModel):
    status: str
    session_id: int


class CloseAttendanceResponse(BaseModel):
    status: str
    classroom_id: int
    session_id: int
    closed_at: datetime