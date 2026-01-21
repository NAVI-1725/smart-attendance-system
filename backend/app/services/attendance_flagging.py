# backend\app\services\attendance_flagging.py
from typing import Optional
from app.schemas.attendance import BleEvidence
from app.models.attendance import AttendanceStatus


def classify_attendance(
    ble: Optional[BleEvidence],
) -> AttendanceStatus:
    if ble is None:
        return AttendanceStatus.FLAGGED

    if ble.overall in ("STRONG", "MEDIUM"):
        return AttendanceStatus.CONFIRMED

    return AttendanceStatus.FLAGGED
