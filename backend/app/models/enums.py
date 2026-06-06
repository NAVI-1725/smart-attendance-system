# backend/app/models/enums.py

from enum import Enum


class AttendanceStatus(str, Enum):
    """
    Final attendance decision stored in the attendance table.

    Lifecycle:

    Attendance Submission:
        CONFIRMED
        FLAGGED

    Faculty Review:
        CONFIRMED
        REJECTED
    """

    CONFIRMED = "CONFIRMED"
    FLAGGED = "FLAGGED"
    REJECTED = "REJECTED"


class AttendanceSessionStatus(str, Enum):
    """
    Lifecycle state of an attendance session.

    ACTIVE:
        Session is accepting attendance submissions.

    CLOSED:
        Faculty manually closed the session.

    EXPIRED:
        Session automatically expired after expires_at.
    """

    ACTIVE = "ACTIVE"
    CLOSED = "CLOSED"
    EXPIRED = "EXPIRED"