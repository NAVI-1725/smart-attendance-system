# backend\app\models\user.py
from sqlalchemy import Column, Integer, String, Boolean, DateTime
from sqlalchemy.sql import func
from enum import Enum

# NOTE:
# Alembic uses app.db.base.Base as the canonical metadata source.
# This import is aligned to ensure the User table is registered
# in the same MetaData used by Alembic autogeneration.
from app.db.base import Base


class UserRole(str, Enum):
    admin = "admin"
    faculty = "faculty"
    student = "student"


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    full_name = Column(String, nullable=False)
    role = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
