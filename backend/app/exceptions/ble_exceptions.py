# backend/app/exceptions/ble_exceptions.py

from app.core.errors import ApiError, ErrorCode


class InvalidBLEEvidence(ApiError):
    def __init__(self, detail="Invalid BLE evidence"):
        super().__init__(
            ErrorCode.INVALID_BLE_EVIDENCE,
            detail,
            status_code=400,
        )


class ReplayAttackDetected(ApiError):
    def __init__(self):
        super().__init__(
            ErrorCode.INVALID_BLE_EVIDENCE,
            "Replay attack detected",
            status_code=400,
        )
