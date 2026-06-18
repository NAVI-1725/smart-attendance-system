# backend/app/models/__init__.py
from app.models.user import User as User
from app.models.device import Device as Device
from app.models.attendance import AttendanceAttempt as AttendanceAttempt
from app.models.attendance_ble_evidence import (
    AttendanceBleEvidence as AttendanceBleEvidence,
)
from app.models.attendance_gps_evidence import (
    AttendanceGpsEvidence as AttendanceGpsEvidence,
)
from app.models.classroom import Classroom as Classroom
from app.models.enrollment import Enrollment as Enrollment
from app.models.auth_session import AuthSession as AuthSession
from app.models.attendance_session import AttendanceSession as AttendanceSession
from app.models.attendance_ble_nonce import AttendanceBLENonce as AttendanceBLENonce
from app.models.trusted_ble_beacon import TrustedBLEBeacon as TrustedBLEBeacon
from app.models.beacon_secret import BeaconSecret as BeaconSecret
from app.models.course import Course
from app.models.faculty_course import FacultyCourse
from app.models.course_registration_session import (
    CourseRegistrationSession,
)
from app.models.course_registration_request import (
    CourseRegistrationRequest,
)