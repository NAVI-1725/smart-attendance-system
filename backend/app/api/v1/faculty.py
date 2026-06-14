# backend/app/api/v1/faculty.py

from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func

from app.core.dependencies import get_current_user, get_db, require_faculty
from app.core.domain_rules import (
    ensure_faculty_owns_attendance,
    ensure_faculty_owns_classroom,
)
from app.models.attendance import AttendanceAttempt
from app.models.enums import AttendanceStatus
from app.models.faculty_action_logs import FacultyActionLog
from app.models.attendance_session import AttendanceSession
from app.models.user import User
from app.models.course import Course
from app.schemas.faculty import (
    AttendanceDetailResponse,
    AttendanceEvidenceResponse,
    AttendanceSummaryResponse,
    BleEvidenceResponse,
    FacultyDashboardResponse,
    FacultySessionHistoryItem,
    FlaggedAttendanceItem,
    GpsEvidenceResponse,
)
from app.schemas.faculty_resolution import FacultyResolutionRequest

router = APIRouter(
    tags=["Faculty"],
    dependencies=[Depends(require_faculty)],
)


@router.post("/attendance/resolve")
def resolve_attendance(
    data: FacultyResolutionRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    # 1️⃣ Faculty-only authority (case-safe)
    if current_user.role.upper() != "FACULTY":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Faculty access required",
        )

    # 2️⃣ Attendance existence (CORRECT ORM MODEL)
    attendance = (
        db.query(AttendanceAttempt)
        .filter(AttendanceAttempt.id == data.attendance_id)
        .first()
    )

    if not attendance:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Attendance not found",
        )

    # 3️⃣ Faculty must own classroom
    ensure_faculty_owns_classroom(
        db,
        current_user.id,
        attendance.classroom_id,
    )

    # 4️⃣ Idempotent review enforcement
    if attendance.status in (
        AttendanceStatus.CONFIRMED,
        AttendanceStatus.REJECTED,
    ):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Attendance already reviewed",
        )

    original_status = attendance.status

    # 5️⃣ Apply resolution
    attendance.status = data.new_status

    attendance.reviewed_by = current_user.id

    attendance.reviewed_at = datetime.now(
        timezone.utc,
    )

    attendance.resolution_reason = data.reason

    # 6️⃣ Immutable audit log (exam-critical)
    log = FacultyActionLog(
        faculty_id=current_user.id,
        attendance_id=attendance.id,
        original_status=original_status.value,
        new_status=data.new_status.value,
        resolution_type=(
            "CONFIRM"
            if data.new_status
            == AttendanceStatus.CONFIRMED
            else "REJECT"
        ),
        reason=data.reason,
    )

    db.add(log)
    db.commit()

    return {"status": "resolved"}


@router.get(
    "/attendance/{attendance_id}",
    response_model=AttendanceDetailResponse,
)
def get_attendance_detail(
    attendance_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    attendance = ensure_faculty_owns_attendance(
        db=db,
        faculty_id=current_user.id,
        attendance_id=attendance_id,
    )

    student = (
        db.query(User)
        .filter(
            User.id == attendance.student_id,
        )
        .first()
    )

    session = (
        db.query(AttendanceSession)
        .filter(
            AttendanceSession.id
            == attendance.session_id,
        )
        .first()
    )

    reviewed_by_name = None

    if attendance.reviewed_by is not None:
        reviewer = (
            db.query(User)
            .filter(
                User.id
                == attendance.reviewed_by,
            )
            .first()
        )

        if reviewer:
            reviewed_by_name = (
                reviewer.full_name
            )

    return {
        "attendance_id": attendance.id,
        "student_id": attendance.student_id,
        "session_id": attendance.session_id,
        "status": attendance.status,
        "student_name": (
            student.full_name
            if student
            else ""
        ),
        "course_name": (
            session.course.course_name
            if session
            else ""
        ),
        "reviewed_by": reviewed_by_name,
        "reviewed_at": attendance.reviewed_at,
        "resolution_reason": (
            attendance.resolution_reason
        ),
    }


@router.get(
    "/attendance/{attendance_id}/evidence",
    response_model=AttendanceEvidenceResponse,
)
def get_attendance_evidence(
    attendance_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    attendance = ensure_faculty_owns_attendance(
        db=db,
        faculty_id=current_user.id,
        attendance_id=attendance_id,
    )

    ble_evidence = [
        {
            "beacon_data": evidence.ble_payload,
            "client_timestamp": evidence.client_timestamp,
            "server_received_timestamp": evidence.server_received_timestamp,
        }
        for evidence in attendance.ble_evidence
    ]

    gps = attendance.gps_evidence

    gps_evidence = None
    if gps:
        gps_evidence = {
            "latitude": gps.latitude,
            "longitude": gps.longitude,
            "accuracy_meters": gps.accuracy_meters,
            "distance_from_classroom_meters": gps.distance_from_classroom_meters,
            "validation_result": gps.validation_result,
            "validation_reason": gps.validation_reason,
        }

    return {
        "ble": ble_evidence,
        "gps": gps_evidence,
        "client_timestamp": (
            attendance.ble_evidence[0].client_timestamp
            if attendance.ble_evidence
            else None
        ),
        "server_received_timestamp": (
            attendance.ble_evidence[0].server_received_timestamp
            if attendance.ble_evidence
            else None
        ),
    }


@router.get(
    "/dashboard",
    response_model=FacultyDashboardResponse,
)
def get_dashboard(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    today_start = datetime.now(
        timezone.utc,
    ).replace(
        hour=0,
        minute=0,
        second=0,
        microsecond=0,
    )

    active_sessions = (
        db.query(func.count(AttendanceSession.id))
        .filter(
            AttendanceSession.faculty_id == current_user.id,
            AttendanceSession.is_active == True,
        )
        .scalar()
    )

    flagged_attendance = (
        db.query(func.count(AttendanceAttempt.id))
        .join(
            AttendanceSession,
            AttendanceAttempt.session_id == AttendanceSession.id,
        )
        .filter(
            AttendanceSession.faculty_id == current_user.id,
            AttendanceAttempt.status == AttendanceStatus.FLAGGED,
        )
        .scalar()
    )

    confirmed_today = (
        db.query(func.count(AttendanceAttempt.id))
        .join(
            AttendanceSession,
            AttendanceAttempt.session_id == AttendanceSession.id,
        )
        .filter(
            AttendanceSession.faculty_id == current_user.id,
            AttendanceAttempt.status == AttendanceStatus.CONFIRMED,
            AttendanceAttempt.reviewed_at >= today_start,
        )
        .scalar()
    )

    rejected_today = (
        db.query(func.count(AttendanceAttempt.id))
        .join(
            AttendanceSession,
            AttendanceAttempt.session_id == AttendanceSession.id,
        )
        .filter(
            AttendanceSession.faculty_id == current_user.id,
            AttendanceAttempt.status == AttendanceStatus.REJECTED,
            AttendanceAttempt.reviewed_at >= today_start,
        )
        .scalar()
    )

    return {
        "active_sessions": active_sessions,
        "flagged_attendance": flagged_attendance,
        "confirmed_today": confirmed_today,
        "rejected_today": rejected_today,
    }


@router.get(
    "/sessions",
    response_model=list[FacultySessionHistoryItem],
)
def get_faculty_sessions(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    sessions = (
        db.query(AttendanceSession)
        .filter(AttendanceSession.faculty_id == current_user.id)
        .order_by(AttendanceSession.id.desc())
        .all()
    )

    return [
        {
            "session_id": session.id,
            "course_name": session.course.course_name,
            "status": session.status,
            "started_at": session.started_at,
            "closed_at": session.closed_at,
        }
        for session in sessions
    ]


@router.get(
    "/attendance-summary",
    response_model=AttendanceSummaryResponse,
)
def get_attendance_summary(
    classroom_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    ensure_faculty_owns_classroom(
        db,
        current_user.id,
        classroom_id,
    )

    confirmed = (
        db.query(func.count(AttendanceAttempt.id))
        .filter(
            AttendanceAttempt.classroom_id == classroom_id,
            AttendanceAttempt.status == AttendanceStatus.CONFIRMED,
        )
        .scalar()
    )

    flagged = (
        db.query(func.count(AttendanceAttempt.id))
        .filter(
            AttendanceAttempt.classroom_id == classroom_id,
            AttendanceAttempt.status == AttendanceStatus.FLAGGED,
        )
        .scalar()
    )

    total = (
        db.query(func.count(AttendanceAttempt.id))
        .filter(
            AttendanceAttempt.classroom_id == classroom_id,
        )
        .scalar()
    )

    return {
        "classroom_id": classroom_id,
        "total": total,
        "confirmed": confirmed,
        "flagged": flagged,
    }


@router.get(
    "/flagged-attendance",
    response_model=list[FlaggedAttendanceItem],
)
def get_flagged_attendance(
    classroom_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    ensure_faculty_owns_classroom(
        db,
        current_user.id,
        classroom_id,
    )

    flagged_records = (
        db.query(
            AttendanceAttempt,
            User.full_name,
            Course.course_name,
            AttendanceSession.started_at,
        )
        .join(
            User,
            AttendanceAttempt.student_id == User.id,
        )
        .join(
            AttendanceSession,
            AttendanceAttempt.session_id
            == AttendanceSession.id,
        )
        .join(
            Course,
            AttendanceSession.course_id
            == Course.id,
        )
        .filter(
            AttendanceAttempt.classroom_id == classroom_id,
            AttendanceAttempt.status
            == AttendanceStatus.FLAGGED,
        )
        .order_by(
            AttendanceAttempt.id.desc(),
        )
        .all()
    )

    return [
        {
            "attendance_id": attendance.id,
            "student_name": student_name,
            "course_name": course_name,
            "status": attendance.status.value,
            "timestamp": started_at,
        }
        for (
            attendance,
            student_name,
            course_name,
            started_at,
        ) in flagged_records
    ]


@router.get("/student-history")
def get_student_history(
    student_id: int,
    classroom_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):

    ensure_faculty_owns_classroom(
        db,
        current_user.id,
        classroom_id,
    )

    history = (
        db.query(AttendanceAttempt)
        .filter(
            AttendanceAttempt.student_id == student_id,
            AttendanceAttempt.classroom_id == classroom_id,
        )
        .order_by(AttendanceAttempt.id.desc())
        .all()
    )

    return history