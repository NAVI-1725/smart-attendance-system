# backend\app\api\v1\admin_dashboard.py
from fastapi import (
    APIRouter,
    Depends,
)

from sqlalchemy.orm import Session
from sqlalchemy import func

from app.core.dependencies import require_admin
from app.core.constants.roles import UserRole
from app.db.session import get_db

from app.models.user import User
from app.models.course import Course
from app.models.enrollment import Enrollment
from app.models.classroom import Classroom
from app.models.trusted_ble_beacon import TrustedBLEBeacon
from app.models.device import Device

from app.schemas.admin_dashboard import (
    SystemSummaryResponse,
)

router = APIRouter(
    prefix="/admin",
    tags=["Admin Dashboard"],
    dependencies=[Depends(require_admin)],
)


@router.get(
    "/system-summary",
    response_model=SystemSummaryResponse,
)
def get_system_summary(
    db: Session = Depends(get_db),
):
    students = (
        db.query(func.count(User.id))
        .filter(
            User.role == UserRole.STUDENT.value,
        )
        .scalar()
    )

    faculty = (
        db.query(func.count(User.id))
        .filter(
            User.role == UserRole.FACULTY.value,
        )
        .scalar()
    )

    courses = (
        db.query(func.count(Course.id))
        .scalar()
    )

    enrollments = (
        db.query(func.count(Enrollment.id))
        .scalar()
    )

    classrooms = (
        db.query(func.count(Classroom.id))
        .scalar()
    )

    beacons = (
        db.query(func.count(TrustedBLEBeacon.id))
        .scalar()
    )

    devices_bound = (
        db.query(func.count(Device.id))
        .filter(
            Device.is_active,
        )
        .scalar()
    )

    return {
        "students": students,
        "faculty": faculty,
        "courses": courses,
        "enrollments": enrollments,
        "classrooms": classrooms,
        "beacons": beacons,
        "devices_bound": devices_bound,
    }