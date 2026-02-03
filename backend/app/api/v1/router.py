# backend\app\api\v1\router.py

from fastapi import APIRouter

from app.api.v1 import auth, attendance, devices, faculty, sessions, admin, classrooms

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["Auth"])
api_router.include_router(attendance.router, prefix="/attendance", tags=["Attendance"])
api_router.include_router(devices.router, prefix="/devices", tags=["Devices"])
api_router.include_router(faculty.router, prefix="/faculty", tags=["Faculty"])
api_router.include_router(sessions.router, prefix="/sessions", tags=["Sessions"])
api_router.include_router(classrooms.router)
api_router.include_router(admin.router)
