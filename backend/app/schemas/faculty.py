# backend/app/schemas/faculty.py
from pydantic import BaseModel


class AttendanceSummaryResponse(BaseModel):
    classroom_id: int
    total: int
    confirmed: int
    flagged: int
