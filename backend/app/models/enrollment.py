# backend\app\models\enrollment.py
from sqlalchemy import Column, Integer, ForeignKey, UniqueConstraint
from app.db.base_class import Base


class Enrollment(Base):
    __tablename__ = "enrollments"

    id = Column(Integer, primary_key=True, index=True)

    student_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    classroom_id = Column(Integer, ForeignKey("classrooms.id"), nullable=False)

    __table_args__ = (
        UniqueConstraint("student_id", "classroom_id", name="uq_student_classroom"),
    )
