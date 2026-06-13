# backend\app\schemas\auth.py
from pydantic import BaseModel, EmailStr


class LoginRequest(BaseModel):
    email: EmailStr
    password: str
    device_uuid: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str
    role: str


class ProfileResponse(BaseModel):
    user_id: int
    role: str
    full_name: str
    email: str
    device_id: str | None