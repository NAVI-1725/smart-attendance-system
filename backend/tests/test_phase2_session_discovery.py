# backend\tests\test_phase2_session_discovery.py
# backend/tests/test_phase2_session_discovery.py

from datetime import datetime, timedelta, timezone

from app.models.course import Course
from app.models.enrollment import Enrollment
from app.models.attendance_session import AttendanceSession
from app.models.enums import AttendanceSessionStatus
from app.services.session_discovery_service import (
    get_active_sessions_for_student,
)


def test_student_sees_active_session(
    db,
    student_user,
    faculty_user,
    classroom,
    course,
):
    enrollment = Enrollment(
        student_id=student_user.id,
        course_id=course.id,
    )

    db.add(enrollment)
    db.commit()

    session = AttendanceSession(
        faculty_id=faculty_user.id,
        course_id=course.id,
        classroom_id=classroom.id,
        is_active=True,
        status=AttendanceSessionStatus.ACTIVE,
        expires_at=datetime.now(timezone.utc)
        + timedelta(minutes=30),
    )

    db.add(session)
    db.commit()

    result = get_active_sessions_for_student(
        db,
        student_user.id,
    )

    assert len(result) == 1
    assert result[0].course_id == course.id


def test_student_not_enrolled(
    db,
    student_user,
    faculty_user,
    classroom,
    course,
):
    session = AttendanceSession(
        faculty_id=faculty_user.id,
        course_id=course.id,
        classroom_id=classroom.id,
        is_active=True,
        status=AttendanceSessionStatus.ACTIVE,
        expires_at=datetime.now(timezone.utc)
        + timedelta(minutes=30),
    )

    db.add(session)
    db.commit()

    result = get_active_sessions_for_student(
        db,
        student_user.id,
    )

    assert result == []


def test_expired_session_hidden(
    db,
    student_user,
    faculty_user,
    classroom,
    course,
):
    enrollment = Enrollment(
        student_id=student_user.id,
        course_id=course.id,
    )

    db.add(enrollment)
    db.commit()

    session = AttendanceSession(
        faculty_id=faculty_user.id,
        course_id=course.id,
        classroom_id=classroom.id,
        is_active=False,
        status=AttendanceSessionStatus.EXPIRED,
        expires_at=datetime.now(timezone.utc)
        - timedelta(minutes=5),
    )

    db.add(session)
    db.commit()

    result = get_active_sessions_for_student(
        db,
        student_user.id,
    )

    assert result == []


def test_closed_session_hidden(
    db,
    student_user,
    faculty_user,
    classroom,
    course,
):
    enrollment = Enrollment(
        student_id=student_user.id,
        course_id=course.id,
    )

    db.add(enrollment)
    db.commit()

    session = AttendanceSession(
        faculty_id=faculty_user.id,
        course_id=course.id,
        classroom_id=classroom.id,
        is_active=False,
        status=AttendanceSessionStatus.CLOSED,
        closed_at=datetime.now(timezone.utc),
        expires_at=datetime.now(timezone.utc)
        + timedelta(minutes=30),
    )

    db.add(session)
    db.commit()

    result = get_active_sessions_for_student(
        db,
        student_user.id,
    )

    assert result == []


def test_student_without_enrollments(
    db,
    student_user,
):
    result = get_active_sessions_for_student(
        db,
        student_user.id,
    )

    assert result == []


def test_student_sees_multiple_active_sessions(
    db,
    student_user,
    faculty_user,
    classroom,
):
    course_1 = Course(
        course_code="CS301",
        course_name="Data Structures",
    )

    course_2 = Course(
        course_code="CS302",
        course_name="Algorithms",
    )

    db.add(course_1)
    db.add(course_2)
    db.commit()

    db.refresh(course_1)
    db.refresh(course_2)

    enrollment_1 = Enrollment(
        student_id=student_user.id,
        course_id=course_1.id,
    )

    enrollment_2 = Enrollment(
        student_id=student_user.id,
        course_id=course_2.id,
    )

    db.add(enrollment_1)
    db.add(enrollment_2)
    db.commit()

    session_1 = AttendanceSession(
        faculty_id=faculty_user.id,
        course_id=course_1.id,
        classroom_id=classroom.id,
        is_active=True,
        status=AttendanceSessionStatus.ACTIVE,
        expires_at=datetime.now(timezone.utc)
        + timedelta(minutes=30),
    )

    session_2 = AttendanceSession(
        faculty_id=faculty_user.id,
        course_id=course_2.id,
        classroom_id=classroom.id,
        is_active=True,
        status=AttendanceSessionStatus.ACTIVE,
        expires_at=datetime.now(timezone.utc)
        + timedelta(minutes=40),
    )

    db.add(session_1)
    db.add(session_2)
    db.commit()

    result = get_active_sessions_for_student(
        db,
        student_user.id,
    )

    assert len(result) == 2

    returned_course_ids = {
        session.course_id
        for session in result
    }

    assert course_1.id in returned_course_ids
    assert course_2.id in returned_course_ids


def test_cross_course_isolation(
    db,
    student_user,
    faculty_user,
    classroom,
):
    enrolled_course = Course(
        course_code="CS401",
        course_name="Operating Systems",
    )

    other_course = Course(
        course_code="CS402",
        course_name="Computer Networks",
    )

    db.add(enrolled_course)
    db.add(other_course)
    db.commit()

    db.refresh(enrolled_course)
    db.refresh(other_course)

    enrollment = Enrollment(
        student_id=student_user.id,
        course_id=enrolled_course.id,
    )

    db.add(enrollment)
    db.commit()

    session_1 = AttendanceSession(
        faculty_id=faculty_user.id,
        course_id=enrolled_course.id,
        classroom_id=classroom.id,
        is_active=True,
        status=AttendanceSessionStatus.ACTIVE,
        expires_at=datetime.now(timezone.utc)
        + timedelta(minutes=30),
    )

    session_2 = AttendanceSession(
        faculty_id=faculty_user.id,
        course_id=other_course.id,
        classroom_id=classroom.id,
        is_active=True,
        status=AttendanceSessionStatus.ACTIVE,
        expires_at=datetime.now(timezone.utc)
        + timedelta(minutes=30),
    )

    db.add(session_1)
    db.add(session_2)
    db.commit()

    result = get_active_sessions_for_student(
        db,
        student_user.id,
    )

    assert len(result) == 1
    assert result[0].course_id == enrolled_course.id