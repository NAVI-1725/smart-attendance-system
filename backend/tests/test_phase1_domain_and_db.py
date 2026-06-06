# backend/tests/test_phase1_domain_and_db.py
from datetime import datetime, timedelta, timezone

import pytest

from app.core.domain_rules import (
    ensure_student_enrolled_in_course,
    ensure_faculty_teaches_course,
)
from app.core.errors import ApiError
from app.models.course import Course
from app.models.enrollment import Enrollment
from app.models.faculty_course import FacultyCourse
from app.models.attendance_session import AttendanceSession
from app.models.enums import AttendanceSessionStatus
from app.services.session_cleanup_service import (
    deactivate_expired_sessions,
)


def test_student_enrollment_validation(
    db,
    student_user,
):
    course = Course(
        course_code="TEST101",
        course_name="Testing",
    )

    db.add(course)
    db.commit()
    db.refresh(course)

    enrollment = Enrollment(
        student_id=student_user.id,
        course_id=course.id,
    )

    db.add(enrollment)
    db.commit()

    ensure_student_enrolled_in_course(
        db,
        student_user.id,
        course.id,
    )


def test_student_not_enrolled(
    db,
    student_user,
):
    course = Course(
        course_code="TEST102",
        course_name="Testing",
    )

    db.add(course)
    db.commit()

    with pytest.raises(ApiError):
        ensure_student_enrolled_in_course(
            db,
            student_user.id,
            course.id,
        )


def test_faculty_course_validation(
    db,
    faculty_user,
):
    course = Course(
        course_code="TEST103",
        course_name="Testing",
    )

    db.add(course)
    db.commit()
    db.refresh(course)

    mapping = FacultyCourse(
        faculty_id=faculty_user.id,
        course_id=course.id,
    )

    db.add(mapping)
    db.commit()

    ensure_faculty_teaches_course(
        db,
        faculty_user.id,
        course.id,
    )


def test_faculty_not_assigned_course(
    db,
    faculty_user,
):
    course = Course(
        course_code="TEST104",
        course_name="Testing",
    )

    db.add(course)
    db.commit()

    with pytest.raises(ApiError):
        ensure_faculty_teaches_course(
            db,
            faculty_user.id,
            course.id,
        )


def test_session_expiration_updates_status(
    db,
    faculty_user,
    classroom,
    course,
):
    expired_session = AttendanceSession(
        faculty_id=faculty_user.id,
        classroom_id=classroom.id,
        course_id=course.id,
        is_active=True,
        expires_at=datetime.now(
            timezone.utc
        )
        - timedelta(minutes=1),
    )

    db.add(expired_session)
    db.commit()

    deactivate_expired_sessions(db)

    db.refresh(expired_session)

    assert expired_session.is_active is False

    assert (
        expired_session.status
        == AttendanceSessionStatus.EXPIRED
    )


def test_enum_values():
    assert (
        AttendanceSessionStatus.ACTIVE.value
        == "ACTIVE"
    )

    assert (
        AttendanceSessionStatus.CLOSED.value
        == "CLOSED"
    )

    assert (
        AttendanceSessionStatus.EXPIRED.value
        == "EXPIRED"
    )