# backend\app\models\faculty_course.py
# backend/app/models/faculty_course.py

from sqlalchemy import (
    Column,
    Integer,
    ForeignKey,
    UniqueConstraint,
)
from sqlalchemy.orm import relationship

from app.db.base_class import Base


class FacultyCourse(Base):
    __tablename__ = "faculty_courses"

    __table_args__ = (
        UniqueConstraint(
            "faculty_id",
            "course_id",
            name="uq_faculty_course",
        ),
    )

    id = Column(
        Integer,
        primary_key=True,
        index=True,
    )

    faculty_id = Column(
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

    faculty = relationship(
        "User",
        back_populates="faculty_courses",
    )

    course = relationship(
        "Course",
        back_populates="faculty_assignments",
    )