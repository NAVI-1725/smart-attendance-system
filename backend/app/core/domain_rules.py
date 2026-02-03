# backend\app\core\domain_rules.py
from sqlalchemy.orm import Session
from app.models.attendance import AttendanceAttempt
from app.models.enrollment import Enrollment
from app.models.session import Session as UserSession
from app.models.classroom import Classroom
from app.core.errors import ApiError, ErrorCode


def ensure_student_enrolled(db: Session, student_id: int, classroom_id: int):
    if not db.query(Enrollment).filter(
        Enrollment.student_id == student_id,
        Enrollment.classroom_id == classroom_id
    ).first():
        raise ApiError(
            ErrorCode.NOT_ENROLLED,
            "Student not enrolled",
            status_code=403,
        )


def ensure_class_active(db: Session, classroom_id: int):
    session = db.query(UserSession).filter(
        UserSession.classroom_id == classroom_id,
        UserSession.is_active == True
    ).first()

    if not session:
        raise ApiError(
            ErrorCode.CLASS_NOT_ACTIVE,
            "No active classroom",
            status_code=404,
        )

    return session


def ensure_attendance_open(db: Session, classroom_id: int):
    locked = db.query(AttendanceAttempt).filter(
        AttendanceAttempt.classroom_id == classroom_id,
        AttendanceAttempt.is_locked == True
    ).first()

    if locked:
        raise ApiError(
            ErrorCode.ATTENDANCE_CLOSED,
            "Attendance is already closed",
            status_code=403,
        )


def ensure_faculty_owns_classroom(db: Session, faculty_id: int, classroom_id: int):
    if not db.query(Classroom).filter(
        Classroom.id == classroom_id,
        Classroom.faculty_id == faculty_id
    ).first():
        raise ApiError(
            ErrorCode.CLASSROOM_NOT_FOUND,
            "Classroom not found",
            status_code=404,
        )
