# backend/app/schemas/session.py

from datetime import datetime

from pydantic import BaseModel

from app.models.enums import (
    AttendanceSessionStatus,
    AttendanceStatus,
)


class StartSessionRequest(BaseModel):
    course_id: int
    classroom_id: int
    duration_minutes: int = 10


class SessionResponse(BaseModel):
    session_id: int
    expires_at: datetime
    duration_minutes: int


class ActiveSessionResponse(BaseModel):
    session_id: int
    course_id: int
    classroom_id: int
    expires_at: datetime
    duration_minutes: int


class StudentActiveSessionResponse(BaseModel):
    session_id: int

    course_id: int
    course_code: str
    course_name: str

    faculty_id: int
    faculty_name: str

    classroom_id: int
    classroom_name: str

    started_at: datetime
    expires_at: datetime

    status: AttendanceSessionStatus


class SessionAttendanceRecord(BaseModel):
    attendance_id: int
    student_id: int
    status: AttendanceStatus


class SessionAttendanceResponse(BaseModel):
    confirmed: int
    flagged: int
    rejected: int
    records: list[SessionAttendanceRecord]