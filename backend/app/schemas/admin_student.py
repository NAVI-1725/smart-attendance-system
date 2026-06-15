# backend/app/schemas/admin_student.py

from pydantic import BaseModel, EmailStr


class StudentCreate(BaseModel):
    full_name: str
    email: EmailStr
    password: str


class StudentUpdate(BaseModel):
    full_name: str
    email: EmailStr
    is_active: bool


class StudentResponse(BaseModel):
    id: int
    full_name: str
    email: str
    role: str
    is_active: bool

    class Config:
        from_attributes = True