# backend\app\models\faculty_action_logs.py
from sqlalchemy import Column, Integer, String, Text, ForeignKey, DateTime
from sqlalchemy.sql import func
from app.db.base import Base


class FacultyActionLog(Base):
    __tablename__ = "faculty_action_logs"

    id = Column(Integer, primary_key=True, index=True)

    faculty_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="RESTRICT"),
        nullable=False,
    )

    attendance_id = Column(
        Integer,
        ForeignKey("attendance.id", ondelete="RESTRICT"),
        nullable=False,
    )

    original_status = Column(String(20), nullable=False)
    new_status = Column(String(20), nullable=False)

    reason = Column(Text, nullable=False)

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )
