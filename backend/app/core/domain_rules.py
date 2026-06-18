################################################################################
# FILE: backend/app/core/domain_rules.py
################################################################################

from datetime import datetime, timezone

from sqlalchemy.orm import Session

from app.models.enrollment import Enrollment
from app.models.attendance import AttendanceAttempt
from app.models.attendance_session import AttendanceSession
from app.models.classroom import Classroom
from app.models.faculty_course import FacultyCourse
from app.models.course_registration_session import (
    CourseRegistrationSession,
)
from app.core.errors import ApiError, ErrorCode
from app.services.session_cleanup_service import (
    deactivate_expired_sessions,
)


def ensure_student_enrolled_in_course(
    db: Session,
    student_id: int,
    course_id: int,
):
    if (
        not db.query(Enrollment)
        .filter(
            Enrollment.student_id == student_id,
            Enrollment.course_id == course_id,
        )
        .first()
    ):
        raise ApiError(
            ErrorCode.NOT_ENROLLED,
            "Student not enrolled",
            status_code=403,
        )


def ensure_class_active(
    db: Session,
    classroom_id: int,
):
    deactivate_expired_sessions(db)

    now = datetime.now(timezone.utc)

    session = (
        db.query(AttendanceSession)
        .filter(
            AttendanceSession.classroom_id == classroom_id,
            AttendanceSession.is_active == True,
            AttendanceSession.closed_at.is_(None),
            AttendanceSession.expires_at > now,
        )
        .first()
    )

    if not session:
        raise ApiError(
            ErrorCode.CLASS_NOT_ACTIVE,
            "No active classroom",
            status_code=404,
        )

    return session


def ensure_faculty_owns_classroom(
    db: Session,
    faculty_id: int,
    classroom_id: int,
):
    if (
        not db.query(Classroom)
        .filter(
            Classroom.id == classroom_id,
            Classroom.faculty_id == faculty_id,
        )
        .first()
    ):
        raise ApiError(
            ErrorCode.CLASSROOM_NOT_FOUND,
            "Classroom not found",
            status_code=404,
        )


def ensure_faculty_teaches_course(
    db: Session,
    faculty_id: int,
    course_id: int,
):
    if (
        not db.query(FacultyCourse)
        .filter(
            FacultyCourse.faculty_id == faculty_id,
            FacultyCourse.course_id == course_id,
        )
        .first()
    ):
        raise ApiError(
            ErrorCode.NOT_AUTHORIZED,
            "Faculty not assigned to course",
            status_code=403,
        )


def ensure_faculty_owns_session(
    db: Session,
    faculty_id: int,
    session_id: int,
):
    session = (
        db.query(AttendanceSession)
        .filter(
            AttendanceSession.id == session_id,
        )
        .first()
    )

    if not session:
        raise ApiError(
            ErrorCode.SESSION_MISSING,
            "Session not found",
            status_code=404,
        )

    if session.faculty_id != faculty_id:
        raise ApiError(
            ErrorCode.NOT_AUTHORIZED,
            "Faculty does not own session",
            status_code=403,
        )

    return session


def ensure_faculty_owns_attendance(
    db: Session,
    faculty_id: int,
    attendance_id: int,
):
    attendance = (
        db.query(AttendanceAttempt)
        .filter(
            AttendanceAttempt.id == attendance_id,
        )
        .first()
    )

    if not attendance:
        raise ApiError(
            ErrorCode.NOT_FOUND,
            "Attendance not found",
            status_code=404,
        )

    session = (
        db.query(AttendanceSession)
        .filter(
            AttendanceSession.id == attendance.session_id,
        )
        .first()
    )

    if not session or session.faculty_id != faculty_id:
        raise ApiError(
            ErrorCode.NOT_AUTHORIZED,
            "Faculty does not own attendance",
            status_code=403,
        )

    return attendance


def ensure_faculty_owns_registration_session(
    db: Session,
    faculty_id: int,
    session_id: int,
):
    registration_session = (
        db.query(CourseRegistrationSession)
        .filter(
            CourseRegistrationSession.id == session_id,
        )
        .first()
    )

    if not registration_session:
        raise ApiError(
            ErrorCode.NOT_FOUND,
            "Registration session not found",
            status_code=404,
        )

    if registration_session.faculty_id != faculty_id:
        raise ApiError(
            ErrorCode.NOT_AUTHORIZED,
            "Faculty does not own registration session",
            status_code=403,
        )

    return registration_session

################################################################################
# END FILE: backend/app/core/domain_rules.py
################################################################################