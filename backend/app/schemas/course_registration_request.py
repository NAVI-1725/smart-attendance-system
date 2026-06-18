# backend/app/schemas/course_registration_request.py

from datetime import datetime
from typing import Optional

from pydantic import BaseModel

from app.models.enums import RegistrationRequestStatus


class RegistrationRequestResponse(BaseModel):
    id: int
    student_id: int
    student_name: str
    status: RegistrationRequestStatus

    class Config:
        from_attributes = True


class RegistrationRequestListResponse(BaseModel):
    requests: list[RegistrationRequestResponse]

    class Config:
        from_attributes = True


class ApproveRequestResponse(BaseModel):
    message: str


class RejectRequestResponse(BaseModel):
    message: str


class BulkReviewResponse(BaseModel):
    message: str
    count: int

    