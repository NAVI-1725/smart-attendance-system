# backend/app/schemas/admin_course.py

from pydantic import BaseModel, Field


class CourseCreate(BaseModel):
    course_code: str = Field(
        ...,
        min_length=1,
        max_length=50,
    )

    course_name: str = Field(
        ...,
        min_length=1,
        max_length=255,
    )


class CourseUpdate(BaseModel):
    course_code: str = Field(
        ...,
        min_length=1,
        max_length=50,
    )

    course_name: str = Field(
        ...,
        min_length=1,
        max_length=255,
    )


class CourseResponse(BaseModel):
    id: int
    course_code: str
    course_name: str

    class Config:
        from_attributes = True