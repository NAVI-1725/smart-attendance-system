# backend\scripts\create_phase2_validation_session.py

import sys
from pathlib import Path
from datetime import datetime, timedelta, timezone

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from app.db.session import SessionLocal
from app.models.attendance_session import AttendanceSession
from app.models.enums import AttendanceSessionStatus


def main():
    db = SessionLocal()

    try:
        session = AttendanceSession(
            faculty_id=1,
            course_id=1,
            classroom_id=1,
            status=AttendanceSessionStatus.ACTIVE,
            is_active=True,
            started_at=datetime.now(timezone.utc),
            expires_at=datetime.now(timezone.utc)
            + timedelta(minutes=30),
            duration_minutes=30,
        )

        db.add(session)
        db.commit()
        db.refresh(session)

        print()
        print("SUCCESS")
        print(f"Session ID      : {session.id}")
        print(f"Faculty ID      : {session.faculty_id}")
        print(f"Course ID       : {session.course_id}")
        print(f"Classroom ID    : {session.classroom_id}")
        print(f"Status          : {session.status}")
        print(f"Expires At      : {session.expires_at}")

    finally:
        db.close()


if __name__ == "__main__":
    main()