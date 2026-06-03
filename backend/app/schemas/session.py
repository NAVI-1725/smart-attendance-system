# backend/app/schemas/session.py

from datetime import datetime

from pydantic import BaseModel


class StartSessionRequest(BaseModel):
    classroom_id: int
    duration_minutes: int = 10


class SessionResponse(BaseModel):
    session_id: int
    expires_at: datetime
    duration_minutes: int


class ActiveSessionResponse(BaseModel):
    session_id: int
    classroom_id: int
    expires_at: datetime
    duration_minutes: int