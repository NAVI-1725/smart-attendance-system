# backend/app/schemas/admin_faculty_course.py

from pydantic import BaseModel


class FacultyCourseCreate(BaseModel):
    faculty_id: int
    course_id: int


class FacultyCourseResponse(BaseModel):
    id: int

    faculty_id: int
    faculty_name: str

    course_id: int
    course_code: str
    course_name: str

    class Config:
        from_attributes = True