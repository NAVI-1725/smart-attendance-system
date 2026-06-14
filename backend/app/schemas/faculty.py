################################################################################
# FILE: backend/app/schemas/faculty.py
################################################################################

from datetime import datetime

from pydantic import BaseModel

from app.models.enums import (
    AttendanceSessionStatus,
    AttendanceStatus,
    GPSValidationResult,
)


class AttendanceSummaryResponse(BaseModel):
    classroom_id: int
    total: int
    confirmed: int
    flagged: int


class FacultySessionHistoryItem(BaseModel):
    session_id: int
    course_name: str
    status: AttendanceSessionStatus
    started_at: datetime
    closed_at: datetime | None


class AttendanceDetailResponse(BaseModel):
    attendance_id: int
    student_id: int
    session_id: int
    status: AttendanceStatus

    student_name: str
    course_name: str

    reviewed_by: str | None
    reviewed_at: datetime | None

    resolution_reason: str | None


class FlaggedAttendanceItem(BaseModel):
    attendance_id: int
    student_name: str
    course_name: str
    status: str
    timestamp: datetime


class BleEvidenceResponse(BaseModel):
    beacon_data: dict | None
    client_timestamp: datetime | None
    server_received_timestamp: datetime | None


class GpsEvidenceResponse(BaseModel):
    latitude: float
    longitude: float
    accuracy_meters: float
    distance_from_classroom_meters: float | None
    validation_result: GPSValidationResult | None
    validation_reason: str | None


class AttendanceEvidenceResponse(BaseModel):
    ble: list[BleEvidenceResponse]
    gps: GpsEvidenceResponse | None

    client_timestamp: datetime | None
    server_received_timestamp: datetime | None


class FacultyDashboardResponse(BaseModel):
    active_sessions: int
    flagged_attendance: int
    confirmed_today: int
    rejected_today: int


class FacultyCourseItem(BaseModel):
    course_id: int
    course_code: str
    course_name: str
    student_count: int
    active_session: bool


class FacultyCourseDetail(BaseModel):
    course_id: int

    course_code: str
    course_name: str

    student_count: int

    active_session: bool
    active_session_id: int | None


class CourseStudentItem(BaseModel):
    student_id: int
    student_name: str
    attendance_percentage: float


class StudentHistoryItem(BaseModel):
    attendance_id: int
    course_name: str
    status: str
    timestamp: datetime
