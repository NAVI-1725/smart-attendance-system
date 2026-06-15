# backend\app\schemas\admin_dashboard.py
from pydantic import BaseModel


class SystemSummaryResponse(BaseModel):
    students: int
    faculty: int
    courses: int
    enrollments: int
    classrooms: int
    beacons: int
    devices_bound: int