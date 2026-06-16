# backend/app/schemas/course_registration_session.py

from pydantic import BaseModel


class StartRegistrationSessionRequest(BaseModel):
    course_id: int


class RegistrationSessionResponse(BaseModel):
    id: int

    course_id: int
    course_code: str
    course_name: str

    faculty_id: int

    is_active: bool

    class Config:
        from_attributes = True


class JoinRegistrationResponse(BaseModel):
    message: str


class CloseRegistrationResponse(BaseModel):
    message: str