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
    scan_window: int = 10


class BleEvidence(BaseModel):
    overall: str
    per_beacon: Dict[str, BeaconEvidence]


class GPSEvidenceRequest(BaseModel):
    latitude: float
    longitude: float
    accuracy_meters: float
    captured_at: datetime


class AttendanceAttemptRequest(BaseModel):
    session_id: str
    ble_evidence: BleEvidence
    gps_evidence: GPSEvidenceRequest


class AttendanceJoinResponse(BaseModel):
    status: str


class AttendanceSubmitResponse(BaseModel):
    attempt_id: str
    session_id: str
    student_id: str
    timestamp: str
    status: str
    is_flagged: bool


class AttendanceHistoryItem(BaseModel):
    course_code: str
    course_name: str
    status: str
    timestamp: datetime


class CloseAttendanceResponse(BaseModel):
    status: str
    classroom_id: int
    session_id: int
    closed_at: datetime


class AttendanceSnapshotResponse(BaseModel):
    id: int
    student_id: int
    classroom_id: int
    session_id: int
    status: str


class BleEvidenceSnapshotResponse(BaseModel):
    attendance_id: int
    ble_payload: dict
    created_at: datetime


class GpsEvidenceSnapshotResponse(BaseModel):
    attendance_id: int

    latitude: float
    longitude: float
    accuracy_meters: float
    captured_at: datetime

    distance_from_classroom_meters: float | None

    validation_result: str | None
    validation_reason: str | None

    created_at: datetime


class AttendanceEvidenceResponse(BaseModel):
    attendance: AttendanceSnapshotResponse
    ble_evidence: BleEvidenceSnapshotResponse | None
    gps_evidence: GpsEvidenceSnapshotResponse | None