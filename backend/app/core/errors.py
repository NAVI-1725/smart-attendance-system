# backend\app\core\errors.py
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
