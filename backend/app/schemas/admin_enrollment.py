# backend/app/schemas/admin_enrollment.py

from pydantic import BaseModel


class EnrollmentCreate(BaseModel):
    student_id: int
    course_id: int


class EnrollmentResponse(BaseModel):
    id: int

    student_id: int
    student_name: str

    course_id: int
    course_code: str
    course_name: str

    class Config:
        from_attributes = True