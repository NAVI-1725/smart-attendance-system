# backend\tests\conftest.py
from pathlib import Path
import sys
from datetime import datetime, timedelta, timezone

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

ROOT_DIR = Path(__file__).resolve().parents[1]

if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from app.db.base import Base
from app.models.user import User
from app.models.course import Course
from app.models.classroom import Classroom
from app.models.attendance_session import AttendanceSession

# Shared test database
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"
engine = create_engine(SQLALCHEMY_DATABASE_URL)

TestingSessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
)


@pytest.fixture(scope="function")
def db():
    Base.metadata.create_all(bind=engine)
    session = TestingSessionLocal()

    try:
        yield session
    finally:
        session.close()
        Base.metadata.drop_all(bind=engine)


@pytest.fixture()
def faculty_user(db):
    faculty = User(
        email="faculty@test.com",
        password_hash="hashed",
        full_name="Faculty",
        role="faculty",
    )

    db.add(faculty)
    db.commit()
    db.refresh(faculty)

    return faculty


@pytest.fixture()
def student_user(db):
    student = User(
        email="student@test.com",
        password_hash="hashed",
        full_name="Student",
        role="student",
    )

    db.add(student)
    db.commit()
    db.refresh(student)

    return student


@pytest.fixture()
def course(db):
    course = Course(
        course_code="CSE101",
        course_name="Computer Science",
    )

    db.add(course)
    db.commit()
    db.refresh(course)

    return course


@pytest.fixture()
def classroom(db, faculty_user):
    classroom = Classroom(
        name="AP Classroom",
        faculty_id=faculty_user.id,
        latitude=16.5062,
        longitude=80.6480,
        gps_radius_meters=50,
    )

    db.add(classroom)
    db.commit()
    db.refresh(classroom)

    return classroom


@pytest.fixture()
def attendance_session(
    db,
    faculty_user,
    classroom,
    course,
):
    session = AttendanceSession(
        faculty_id=faculty_user.id,
        course_id=course.id,
        classroom_id=classroom.id,
        is_active=True,
        expires_at=datetime.now(timezone.utc)
        + timedelta(minutes=30),
    )

    db.add(session)
    db.commit()
    db.refresh(session)

    return session