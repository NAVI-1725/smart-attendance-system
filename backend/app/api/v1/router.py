# backend\app\api\v1\router.py

from fastapi import APIRouter

from app.api.v1 import (
    auth,
    attendance,
    devices,
    faculty,
    sessions,
    admin,
    classrooms,
    beacons,
    admin_courses,
    admin_faculty_courses,
    admin_enrollments,
    admin_students,
    admin_faculty,
    admin_dashboard,
    course_registration_sessions,
    claims,
)

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["Auth"])
api_router.include_router(attendance.router, prefix="/attendance", tags=["Attendance"])
api_router.include_router(devices.router, prefix="/devices", tags=["Devices"])
api_router.include_router(faculty.router, prefix="/faculty", tags=["Faculty"])
api_router.include_router(sessions.router, prefix="/sessions", tags=["Sessions"])
api_router.include_router(
    claims.router,
    prefix="/claims",
    tags=["Claims"],
)
api_router.include_router(classrooms.router)
api_router.include_router(beacons.router)
api_router.include_router(admin.router)
api_router.include_router(admin_courses.router)
api_router.include_router(admin_faculty_courses.router)
api_router.include_router(admin_enrollments.router)
api_router.include_router(admin_students.router)
api_router.include_router(admin_faculty.router)
api_router.include_router(admin_dashboard.router)
api_router.include_router(course_registration_sessions.router)