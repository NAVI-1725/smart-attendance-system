from pydantic import BaseModel, EmailStr

class LoginRequest(BaseModel):
    email: EmailStr
    password: str
    device_uuid: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str
    role: str
