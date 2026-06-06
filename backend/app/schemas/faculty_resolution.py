# backend\app\schemas\faculty_resolution.py

from pydantic import BaseModel, Field

from app.models.enums import AttendanceStatus


class FacultyResolutionRequest(BaseModel):
    attendance_id: int
    new_status: AttendanceStatus
    reason: str = Field(..., min_length=10)