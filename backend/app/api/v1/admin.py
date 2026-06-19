# backend\app\api\v1\admin.py

from fastapi import (
    APIRouter,
    Depends,
    UploadFile,
    File,
)
from sqlalchemy.orm import Session
from sqlalchemy import or_
from sqlalchemy import func

from app.core.dependencies import require_admin
from app.db.session import get_db

from app.models.user import User
from app.models.course import Course
from app.models.classroom import Classroom
from app.models.device import Device
from app.models.enrollment import Enrollment
from app.models.faculty_course import FacultyCourse
from app.models.trusted_ble_beacon import TrustedBLEBeacon

from app.schemas.device import (
    DeviceUnbindRequest,
    DeviceSearchResponse,
)

from app.schemas.beacon_import import (
    BeaconImportResult,
)

from app.services.device_binding_service import (
    DeviceBindingService,
)

from app.services.beacon_import_service import (
    import_beacons_from_excel,
)

router = APIRouter(
    prefix="/admin",
    tags=["admin"],
    dependencies=[Depends(require_admin)],
)


@router.get("/ping")
def admin_ping():
    return {"status": "admin ok"}


@router.get("/system-summary")
def get_system_summary(
    db: Session = Depends(get_db),
):
    student_count = (
        db.query(User)
        .filter(User.role == "student")
        .count()
    )

    faculty_count = (
        db.query(User)
        .filter(User.role == "faculty")
        .count()
    )

    course_count = (
        db.query(Course)
        .count()
    )

    enrollment_count = (
        db.query(Enrollment)
        .count()
    )

    classroom_count = (
        db.query(Classroom)
        .count()
    )

    beacon_count = (
        db.query(TrustedBLEBeacon)
        .count()
    )

    device_count = (
        db.query(Device)
        .count()
    )

    faculty_course_count = (
        db.query(FacultyCourse)
        .count()
    )

    return {
        "students": student_count,
        "faculty": faculty_count,
        "courses": course_count,
        "faculty_courses": faculty_course_count,
        "enrollments": enrollment_count,
        "classrooms": classroom_count,
        "beacons": beacon_count,
        "devices_bound": device_count,
    }


@router.get(
    "/device/search",
    response_model=list[DeviceSearchResponse],
)
def search_users(
    query: str,
    db: Session = Depends(get_db),
):
    search = f"%{query.strip()}%"

    users = (
        db.query(User)
        .filter(
            or_(
                User.full_name.ilike(search),
                User.email.ilike(search),
            )
        )
        .limit(20)
        .all()
    )

    return users


@router.post("/device/unbind")
def unbind_device(
    data: DeviceUnbindRequest,
    db: Session = Depends(get_db),
):
    DeviceBindingService(
        db,
    ).unbind_device(
        data.student_id,
    )

    return {
        "message":
            "Device unbound successfully",
    }


@router.post(
    "/beacons/import",
    response_model=BeaconImportResult,
)
def import_beacons(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    return import_beacons_from_excel(
        db,
        file,
    )