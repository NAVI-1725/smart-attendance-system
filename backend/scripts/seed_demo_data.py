# backend/scripts/seed_demo_data.py

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from sqlalchemy.orm import Session

from app.db.session import SessionLocal

from app.models.user import User
from app.models.course import Course
from app.models.classroom import Classroom
from app.models.enrollment import Enrollment
from app.models.faculty_course import FacultyCourse
from app.models.trusted_ble_beacon import TrustedBLEBeacon
from app.models.beacon_secret import BeaconSecret

from app.core.constants.roles import UserRole


PASSWORD_HASH = (
    "$2b$12$IOsZkngVR18Oilez1x/BQewi5y70C1bZ5cGPWjhCSKT/kraok9JJe"
)


def seed_users(db: Session):
    faculty = []

    for i in range(1, 4):
        user = User(
            email=f"faculty{i}@iiitr.ac.in",
            password_hash=PASSWORD_HASH,
            full_name=f"Faculty {i}",
            role=UserRole.FACULTY.value,
            is_active=True,
        )
        db.add(user)
        faculty.append(user)

    students = []

    for i in range(1, 16):
        user = User(
            email=f"student{i:02d}@iiitr.ac.in",
            password_hash=PASSWORD_HASH,
            full_name=f"Student {i:02d}",
            role=UserRole.STUDENT.value,
            is_active=True,
        )
        db.add(user)
        students.append(user)

    db.commit()

    return faculty, students


def seed_courses(db: Session):
    courses = [
        Course(
            course_code="CSE101",
            course_name="Programming Fundamentals",
        ),
        Course(
            course_code="CSE201",
            course_name="Data Structures",
        ),
        Course(
            course_code="CSE301",
            course_name="Database Systems",
        ),
        Course(
            course_code="AI401",
            course_name="Artificial Intelligence",
        ),
        Course(
            course_code="DS501",
            course_name="Data Science",
        ),
    ]

    db.add_all(courses)
    db.commit()

    return courses


def seed_classrooms(db: Session, faculty):
    classrooms = [
        Classroom(
            name="LH-1",
            faculty_id=faculty[0].id,
            latitude=17.5937000,
            longitude=78.1234000,
            gps_radius_meters=50,
        ),
        Classroom(
            name="LH-2",
            faculty_id=faculty[1].id,
            latitude=17.5938000,
            longitude=78.1235000,
            gps_radius_meters=50,
        ),
        Classroom(
            name="LAB-A",
            faculty_id=faculty[2].id,
            latitude=17.5939000,
            longitude=78.1236000,
            gps_radius_meters=50,
        ),
        Classroom(
            name="LAB-B",
            faculty_id=faculty[0].id,
            latitude=17.5940000,
            longitude=78.1237000,
            gps_radius_meters=50,
        ),
    ]

    db.add_all(classrooms)
    db.commit()

    return classrooms


def seed_faculty_courses(db: Session, faculty, courses):
    assignments = [
        FacultyCourse(
            faculty_id=faculty[0].id,
            course_id=courses[0].id,
        ),
        FacultyCourse(
            faculty_id=faculty[0].id,
            course_id=courses[1].id,
        ),
        FacultyCourse(
            faculty_id=faculty[1].id,
            course_id=courses[2].id,
        ),
        FacultyCourse(
            faculty_id=faculty[1].id,
            course_id=courses[3].id,
        ),
        FacultyCourse(
            faculty_id=faculty[2].id,
            course_id=courses[4].id,
        ),
    ]

    db.add_all(assignments)
    db.commit()


def seed_enrollments(db: Session, students, courses):
    enrollments = []

    course_map = {
        courses[0].id: students[0:3],
        courses[1].id: students[3:6],
        courses[2].id: students[6:9],
        courses[3].id: students[9:12],
        courses[4].id: students[12:15],
    }

    for course_id, student_group in course_map.items():
        for student in student_group:
            enrollments.append(
                Enrollment(
                    student_id=student.id,
                    course_id=course_id,
                )
            )

    db.add_all(enrollments)
    db.commit()


def seed_beacons(db: Session, classrooms):
    beacon_data = [
        (
            classrooms[0],
            "550e8400-e29b-41d4-a716-446655440001",
            "BEACON-LH1",
            "demo-secret-lh1",
        ),
        (
            classrooms[1],
            "550e8400-e29b-41d4-a716-446655440002",
            "BEACON-LH2",
            "demo-secret-lh2",
        ),
        (
            classrooms[2],
            "550e8400-e29b-41d4-a716-446655440003",
            "BEACON-LABA",
            "demo-secret-laba",
        ),
        (
            classrooms[3],
            "550e8400-e29b-41d4-a716-446655440004",
            "BEACON-LABB",
            "demo-secret-labb",
        ),
    ]

    for classroom, uuid, name, secret in beacon_data:
        beacon = TrustedBLEBeacon(
            classroom_id=classroom.id,
            beacon_uuid=uuid,
            beacon_name=name,
            is_active=True,
        )

        db.add(beacon)
        db.flush()

        db.add(
            BeaconSecret(
                beacon_id=beacon.id,
                secret_key=secret,
                is_active=True,
            )
        )

    db.commit()


def main():
    db = SessionLocal()

    try:
        print("Seeding users...")
        faculty, students = seed_users(db)

        print("Seeding courses...")
        courses = seed_courses(db)

        print("Seeding classrooms...")
        classrooms = seed_classrooms(db, faculty)

        print("Seeding faculty-course assignments...")
        seed_faculty_courses(db, faculty, courses)

        print("Seeding enrollments...")
        seed_enrollments(db, students, courses)

        print("Seeding BLE beacons...")
        seed_beacons(db, classrooms)

        print()
        print("SUCCESS")
        print("Faculty: 3")
        print("Students: 15")
        print("Courses: 5")
        print("Classrooms: 4")
        print("FacultyCourse: 5")
        print("Enrollments: 15")
        print("TrustedBLEBeacons: 4")
        print("BeaconSecrets: 4")

    finally:
        db.close()


if __name__ == "__main__":
    main()