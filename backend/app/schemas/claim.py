# backend/app/schemas/claim.py

from datetime import datetime

from pydantic import BaseModel, Field

from app.models.enums import (
    AttendanceStatus,
    ClaimStatus,
)


class ClaimCreateRequest(BaseModel):
    attendance_id: int
    reason: str = Field(
        min_length=1,
        max_length=2000,
    )


class ClaimResolutionRequest(BaseModel):
    resolution_reason: str = Field(
        min_length=1,
        max_length=2000,
    )


class ClaimResponse(BaseModel):
    id: int
    attendance_id: int
    student_id: int
    original_attendance_status: AttendanceStatus
    status: ClaimStatus
    reason: str
    created_at: datetime

    class Config:
        from_attributes = True


class ClaimDetailResponse(BaseModel):
    id: int
    attendance_id: int
    student_id: int
    original_attendance_status: AttendanceStatus
    reason: str
    status: ClaimStatus

    claim_resolved_by: int | None = None
    claim_resolved_at: datetime | None = None
    claim_resolution_reason: str | None = None

    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class ClaimStatisticsResponse(BaseModel):
    total: int
    pending: int
    approved: int
    rejected: int