# backend\app\models\permissions.py
from enum import Enum


class Permission(str, Enum):
    manage_system = "manage_system"
    manage_faculty = "manage_faculty"
    take_attendance = "take_attendance"
