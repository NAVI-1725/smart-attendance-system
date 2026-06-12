# backend/app/services/attendance_evidence_service.py

from app.models.enums import (
    AttendanceEvidenceResult,
    AttendanceStatus,
    GPSValidationResult,
)


def evaluate_evidence(
    ble_result: AttendanceStatus,
    gps_result: GPSValidationResult,
) -> AttendanceEvidenceResult:
    """
    Evaluate BLE and GPS evidence and produce a final
    evidence-level decision.

    Fusion Rules:

        BLE CONFIRMED
        +
        GPS VALID
        ↓
        CONFIRMED

        Everything Else
        ↓
        FLAGGED

    This service intentionally implements a deterministic
    rule-based decision model.

    Explicitly excluded from Phase 3:

        - Trust scores
        - Confidence scores
        - Weighted scoring
        - Risk engines
        - Machine learning
    """

    if (
        ble_result == AttendanceStatus.CONFIRMED
        and gps_result == GPSValidationResult.VALID
    ):
        return AttendanceEvidenceResult.CONFIRMED

    return AttendanceEvidenceResult.FLAGGED