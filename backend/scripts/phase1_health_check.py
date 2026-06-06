# backend/scripts/phase1_health_check.py
from app.core.database import SessionLocal

from app.models.user import User
from app.models.course import Course
from app.models.enrollment import Enrollment
from app.models.faculty_course import FacultyCourse
from app.models.classroom import Classroom
from app.models.trusted_ble_beacon import TrustedBLEBeacon
from app.models.beacon_secret import BeaconSecret
from app.models.attendance_session import AttendanceSession
from app.models.enums import (
    AttendanceStatus,
    AttendanceSessionStatus,
)

from app.services.session_cleanup_service import (
    deactivate_expired_sessions,
)


def check(condition, message):
    if condition:
        print(f"PASS  {message}")
    else:
        print(f"FAIL  {message}")


def main():
    db = SessionLocal()

    try:

        users = db.query(User).count()
        faculty = db.query(User).filter(User.role == "faculty").count()
        students = db.query(User).filter(User.role == "student").count()

        courses = db.query(Course).count()
        enrollments = db.query(Enrollment).count()
        faculty_courses = db.query(FacultyCourse).count()

        classrooms = db.query(Classroom).count()

        beacons = db.query(TrustedBLEBeacon).count()
        secrets = db.query(BeaconSecret).count()

        check(users == 18, "18 users exist")
        check(faculty == 3, "3 faculty exist")
        check(students == 15, "15 students exist")

        check(courses == 5, "5 courses exist")
        check(enrollments == 15, "15 enrollments exist")
        check(faculty_courses == 5, "5 faculty-course assignments exist")

        check(classrooms == 4, "4 classrooms exist")

        check(beacons == 4, "4 beacons exist")
        check(secrets == 4, "4 beacon secrets exist")

        check(
            AttendanceStatus.REJECTED.value == "REJECTED",
            "AttendanceStatus enum valid",
        )

        check(
            AttendanceSessionStatus.EXPIRED.value == "EXPIRED",
            "AttendanceSessionStatus enum valid",
        )

        orphan_beacons = 0

        for beacon in db.query(TrustedBLEBeacon).all():
            secret = (
                db.query(BeaconSecret)
                .filter(
                    BeaconSecret.beacon_id == beacon.id
                )
                .first()
            )

            if not secret:
                orphan_beacons += 1

        check(
            orphan_beacons == 0,
            "Every beacon has a secret",
        )

        deactivate_expired_sessions(db)

        print("\nPHASE 1 HEALTH CHECK COMPLETE")

    finally:
        db.close()


if __name__ == "__main__":
    main()