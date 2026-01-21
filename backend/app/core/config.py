# backend\app\core\config.py
from pydantic_settings import BaseSettings
from pydantic import Field


class Settings(BaseSettings):
    # Database
    DATABASE_URL: str = Field(...)

    # Security
    SECRET_KEY: str = Field(...)
    ALGORITHM: str = Field(default="HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = Field(default=30)

    # Attendance validation
    BLE_RSSI_THRESHOLD: int = Field(default=-70)
    GPS_RADIUS_METERS: int = Field(default=50)

    # Server
    DEBUG: bool = Field(default=True)
    HOST: str = Field(default="0.0.0.0")
    PORT: int = Field(default=8000)

    class Config:
        env_file = ".env"
        extra = "forbid"


settings = Settings()
