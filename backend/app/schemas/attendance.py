# backend\app\schemas\attendance.py
from typing import Dict, Optional
from pydantic import BaseModel


class BeaconEvidence(BaseModel):
    average_rssi: float
    variance: float
    sample_count: int
    proximity: str


class BleEvidence(BaseModel):
    overall: str
    per_beacon: Dict[str, BeaconEvidence]


class AttendanceAttemptRequest(BaseModel):
    session_id: str
    ble_evidence: Optional[BleEvidence] = None
