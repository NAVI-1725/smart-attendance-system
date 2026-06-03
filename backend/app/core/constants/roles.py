# backend\app\core\constants\roles.py

from enum import Enum


class UserRole(str, Enum):
    ADMIN = "admin"
    FACULTY = "faculty"
    STUDENT = "student"