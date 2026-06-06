# backend/app/models/user.py

from sqlalchemy import Column, Integer, String, Boolean, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

# NOTE:
# Alembic uses app.db.base.Base as the canonical metadata source.
# This import is aligned to ensure the User table is registered
# in the same MetaData used by Alembic autogeneration.
from app.db.base_class import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    full_name = Column(String, nullable=False)
    role = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    faculty_courses = relationship(
        "FacultyCourse",
        back_populates="faculty",
    )

    enrollments = relationship(
        "Enrollment",
        back_populates="student",
    )

    attendance_sessions = relationship(
        "AttendanceSession",
        back_populates="faculty",
    )