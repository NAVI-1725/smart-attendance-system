# backend\app\schemas\faculty_resolution.py
from pydantic import BaseModel, Field
from enum import Enum


class ResolutionStatus(str, Enum):
    CONFIRMED = "CONFIRMED"
    ABSENT = "ABSENT"


class FacultyResolutionRequest(BaseModel):
    attendance_id: int
    new_status: ResolutionStatus
    reason: str = Field(..., min_length=10)
