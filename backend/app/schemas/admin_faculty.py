# backend/app/schemas/admin_faculty.py

from pydantic import BaseModel, EmailStr


class FacultyCreate(BaseModel):
    full_name: str
    email: EmailStr
    password: str


class FacultyUpdate(BaseModel):
    full_name: str
    email: EmailStr
    is_active: bool


class FacultyResponse(BaseModel):
    id: int
    full_name: str
    email: str
    role: str
    is_active: bool

    class Config:
        from_attributes = True