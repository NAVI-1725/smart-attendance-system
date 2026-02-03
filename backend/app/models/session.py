# backend\app\models\session.py
from sqlalchemy import Column, Integer, Boolean, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.db.base_class import Base


class Session(Base):
    __tablename__ = "sessions"

    id = Column(Integer, primary_key=True)
    faculty_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    # NEW — classroom binding
    classroom_id = Column(Integer, ForeignKey("classrooms.id"), nullable=True)

    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
