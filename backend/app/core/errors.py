# backend/app/core/errors.py

from enum import Enum
from fastapi import HTTPException


class ErrorCode(str, Enum):
    NOT_ENROLLED = "NOT_ENROLLED"
    CLASS_NOT_ACTIVE = "CLASS_NOT_ACTIVE"
    ATTENDANCE_CLOSED = "ATTENDANCE_CLOSED"
    NOT_AUTHORIZED = "NOT_AUTHORIZED"
    SESSION_MISSING = "SESSION_MISSING"
    DUPLICATE_ATTENDANCE = "DUPLICATE_ATTENDANCE"
    CLASSROOM_NOT_FOUND = "CLASSROOM_NOT_FOUND"
    NOT_FOUND = "NOT_FOUND"

    SESSION_EXPIRED = "SESSION_EXPIRED"
    SESSION_ALREADY_ACTIVE = "SESSION_ALREADY_ACTIVE"
    SESSION_CLOSED = "SESSION_CLOSED"
    INVALID_SESSION = "INVALID_SESSION"

    INVALID_BLE_EVIDENCE = "INVALID_BLE_EVIDENCE"
    INSUFFICIENT_BLE_EVIDENCE = "INSUFFICIENT_BLE_EVIDENCE"

    BLE_REPLAY_DETECTED = "BLE_REPLAY_DETECTED"
    BLE_TIMESTAMP_INVALID = "BLE_TIMESTAMP_INVALID"
    DEVICE_NOT_TRUSTED = "DEVICE_NOT_TRUSTED"
    DEVICE_BINDING_CONFLICT = "DEVICE_BINDING_CONFLICT"


class ApiError(HTTPException):
    def __init__(self, code: ErrorCode, message: str, status_code: int = 400):
        super().__init__(
            status_code=status_code,
            detail={
                "error": {
                    "code": code,
                    "message": message,
                }
            },
        )