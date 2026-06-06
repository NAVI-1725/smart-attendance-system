# backend\app\models\enrollment.py

from sqlalchemy import Column, Integer, ForeignKey, UniqueConstraint, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base_class import Base


class Enrollment(Base):
    __tablename__ = "enrollments"

    id = Column(Integer, primary_key=True, index=True)

    student_id = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=False,
        index=True,
    )

    course_id = Column(
        Integer,
        ForeignKey("courses.id"),
        nullable=False,
        index=True,
    )

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )

    student = relationship(
        "User",
        back_populates="enrollments",
    )

    course = relationship(
        "Course",
        back_populates="enrollments",
    )

    __table_args__ = (
        UniqueConstraint(
            "student_id",
            "course_id",
            name="uq_student_course",
        ),
    )