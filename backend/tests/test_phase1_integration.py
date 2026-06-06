# backend\tests\test_phase1_integration.py
from datetime import datetime, timedelta, timezone

from app.models.attendance_session import AttendanceSession
from app.models.course import Course
from app.models.enrollment import Enrollment
from app.models.faculty_course import FacultyCourse
from app.models.enums import (
    AttendanceSessionStatus,
)


def test_create_attendance_session(
    db,
    faculty_user,
    classroom,
):
    course = Course(
        course_code="INT101",
        course_name="Integration",
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

    session = AttendanceSession(
        faculty_id=faculty_user.id,
        course_id=course.id,
        classroom_id=classroom.id,
        is_active=True,
        status=AttendanceSessionStatus.ACTIVE,
        expires_at=datetime.now(
            timezone.utc
        )
        + timedelta(minutes=10),
    )

    db.add(session)
    db.commit()

    assert session.id is not None


def test_student_course_enrollment_flow(
    db,
    student_user,
):
    course = Course(
        course_code="INT102",
        course_name="Integration",
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

    found = (
        db.query(Enrollment)
        .filter(
            Enrollment.student_id
            == student_user.id,
            Enrollment.course_id
            == course.id,
        )
        .first()
    )

    assert found is not None


def test_faculty_course_assignment_flow(
    db,
    faculty_user,
):
    course = Course(
        course_code="INT103",
        course_name="Integration",
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

    found = (
        db.query(FacultyCourse)
        .filter(
            FacultyCourse.faculty_id
            == faculty_user.id,
            FacultyCourse.course_id
            == course.id,
        )
        .first()
    )

    assert found is not None