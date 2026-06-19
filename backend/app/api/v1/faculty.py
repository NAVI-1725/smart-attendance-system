# backend/app/api/v1/faculty.py

import csv
import io
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session
from sqlalchemy import func

from app.core.dependencies import get_current_user, get_db, require_faculty
from app.core.domain_rules import (
    ensure_faculty_owns_attendance,
    ensure_faculty_owns_claim,
)
from app.models.attendance import AttendanceAttempt
from app.models.attendance_claim import AttendanceClaim
from app.models.enums import (
    AttendanceStatus,
    ClaimStatus,
)
from app.models.faculty_action_logs import FacultyActionLog
from app.models.attendance_session import AttendanceSession
from app.models.user import User
from app.models.course import Course
from app.models.faculty_course import FacultyCourse
from app.models.enrollment import Enrollment
from app.schemas.faculty import (
    AttendanceDetailResponse,
    AttendanceEvidenceResponse,
    AttendanceSummaryResponse,
    BleEvidenceResponse,
    CourseStudentItem,
    FacultyCourseDetail,
    FacultyCourseItem,
    FacultyDashboardResponse,
    FacultySessionHistoryItem,
    FlaggedAttendanceItem,
    GpsEvidenceResponse,
    StudentHistoryItem,
)
from app.schemas.faculty_resolution import FacultyResolutionRequest
from app.schemas.claim import (
    ClaimResponse,
    ClaimDetailResponse,
    ClaimResolutionRequest,
)
from app.services.session_cleanup_service import (
    deactivate_expired_sessions,
)

router = APIRouter(
    tags=["Faculty"],
    dependencies=[Depends(require_faculty)],
)


@router.get(
    "/courses",
    response_model=list[FacultyCourseItem],
)
def get_faculty_courses(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    deactivate_expired_sessions(db)

    courses = (
        db.query(
            Course,
            func.count(Enrollment.id).label(
                "student_count",
            ),
        )
        .join(
            FacultyCourse,
            FacultyCourse.course_id == Course.id,
        )
        .outerjoin(
            Enrollment,
            Enrollment.course_id == Course.id,
        )
        .filter(
            FacultyCourse.faculty_id == current_user.id,
        )
        .group_by(
            Course.id,
        )
        .all()
    )

    results = []

    for course, student_count in courses:
        active_session = (
            db.query(AttendanceSession)
            .filter(
                AttendanceSession.course_id
                == course.id,
                AttendanceSession.is_active == True,
            )
            .first()
        )

        results.append(
            {
                "course_id": course.id,
                "course_code": course.course_code,
                "course_name": course.course_name,
                "student_count": student_count,
                "active_session": (
                    active_session is not None
                ),
            }
        )

    return results


@router.get(
    "/course/{course_id}",
    response_model=FacultyCourseDetail,
)
def get_course_detail(
    course_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    deactivate_expired_sessions(db)

    course_assignment = (
        db.query(FacultyCourse)
        .filter(
            FacultyCourse.faculty_id == current_user.id,
            FacultyCourse.course_id == course_id,
        )
        .first()
    )

    if not course_assignment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Course not found",
        )

    course = (
        db.query(Course)
        .filter(
            Course.id == course_id,
        )
        .first()
    )

    student_count = (
        db.query(func.count(Enrollment.id))
        .filter(
            Enrollment.course_id == course_id,
        )
        .scalar()
    )

    active_session = (
        db.query(AttendanceSession)
        .filter(
            AttendanceSession.course_id == course_id,
            AttendanceSession.is_active == True,
        )
        .first()
    )

    return {
        "course_id": course.id,
        "course_code": course.course_code,
        "course_name": course.course_name,
        "student_count": student_count,
        "active_session": (
            active_session is not None
        ),
        "active_session_id": (
            active_session.id
            if active_session
            else None
        ),
    }


@router.get(
    "/course/{course_id}/students",
    response_model=list[CourseStudentItem],
)
def get_course_students(
    course_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    course_assignment = (
        db.query(FacultyCourse)
        .filter(
            FacultyCourse.faculty_id == current_user.id,
            FacultyCourse.course_id == course_id,
        )
        .first()
    )

    if not course_assignment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Course not found",
        )

    total_sessions = (
        db.query(func.count(AttendanceSession.id))
        .filter(
            AttendanceSession.course_id == course_id,
        )
        .scalar()
    )

    students = (
        db.query(
            User.id,
            User.full_name,
        )
        .join(
            Enrollment,
            Enrollment.student_id == User.id,
        )
        .filter(
            Enrollment.course_id == course_id,
        )
        .all()
    )

    results = []

    for student_id, student_name in students:
        confirmed_attendances = (
            db.query(func.count(AttendanceAttempt.id))
            .join(
                AttendanceSession,
                AttendanceAttempt.session_id
                == AttendanceSession.id,
            )
            .filter(
                AttendanceSession.course_id == course_id,
                AttendanceAttempt.student_id
                == student_id,
                AttendanceAttempt.status
                == AttendanceStatus.CONFIRMED,
            )
            .scalar()
        )

        attendance_percentage = 0.0

        if total_sessions and total_sessions > 0:
            attendance_percentage = (
                confirmed_attendances
                / total_sessions
            ) * 100

        results.append(
            {
                "student_id": student_id,
                "student_name": student_name,
                "attendance_percentage": round(
                    attendance_percentage,
                    2,
                ),
            }
        )

    return results


@router.get(
    "/course/{course_id}/attendance/export",
)
def export_course_attendance(
    course_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    course_assignment = (
        db.query(FacultyCourse)
        .filter(
            FacultyCourse.faculty_id == current_user.id,
            FacultyCourse.course_id == course_id,
        )
        .first()
    )

    if not course_assignment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Course not found",
        )

    course = (
        db.query(Course)
        .filter(
            Course.id == course_id,
        )
        .first()
    )

    total_sessions = (
        db.query(func.count(AttendanceSession.id))
        .filter(
            AttendanceSession.course_id == course_id,
        )
        .scalar()
    )

    students = (
        db.query(
            User.id,
            User.full_name,
        )
        .join(
            Enrollment,
            Enrollment.student_id == User.id,
        )
        .filter(
            Enrollment.course_id == course_id,
        )
        .order_by(
            User.full_name.asc(),
        )
        .all()
    )

    buffer = io.StringIO()
    writer = csv.writer(buffer)

    writer.writerow(
        [
            "Student ID",
            "Student Name",
            "Present",
            "Absent",
            "Attendance %",
        ]
    )

    for student_id, student_name in students:
        confirmed_attendances = (
            db.query(func.count(AttendanceAttempt.id))
            .join(
                AttendanceSession,
                AttendanceAttempt.session_id
                == AttendanceSession.id,
            )
            .filter(
                AttendanceSession.course_id == course_id,
                AttendanceAttempt.student_id
                == student_id,
                AttendanceAttempt.status
                == AttendanceStatus.CONFIRMED,
            )
            .scalar()
        )

        present_count = confirmed_attendances or 0

        absent_count = max(
            (total_sessions or 0) - present_count,
            0,
        )

        attendance_percentage = 0.0

        if total_sessions and total_sessions > 0:
            attendance_percentage = (
                present_count
                / total_sessions
            ) * 100

        writer.writerow(
            [
                student_id,
                student_name,
                present_count,
                absent_count,
                round(attendance_percentage, 2),
            ]
        )

    buffer.seek(0)

    course_code = (
        course.course_code if course else str(course_id)
    )

    filename = f"attendance_{course_code}.csv"

    return StreamingResponse(
        iter([buffer.getvalue()]),
        media_type="text/csv",
        headers={
            "Content-Disposition": f'attachment; filename="{filename}"',
        },
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

    # 2️⃣ Attendance ownership validation
    attendance = ensure_faculty_owns_attendance(
        db=db,
        faculty_id=current_user.id,
        attendance_id=data.attendance_id,
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

    try:
        db.add(log)
        db.commit()

    except Exception:
        db.rollback()
        raise

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
            if session and session.course
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
    deactivate_expired_sessions(db)

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
    deactivate_expired_sessions(db)

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


@router.get(
    "/claims",
    response_model=list[ClaimResponse],
)
def get_faculty_claims(
    status_filter: ClaimStatus | None = None,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    claims_query = (
        db.query(AttendanceClaim)
        .join(
            AttendanceAttempt,
            AttendanceClaim.attendance_id
            == AttendanceAttempt.id,
        )
        .join(
            AttendanceSession,
            AttendanceAttempt.session_id
            == AttendanceSession.id,
        )
        .filter(
            AttendanceSession.faculty_id
            == current_user.id,
        )
    )

    if status_filter is not None:
        claims_query = claims_query.filter(
            AttendanceClaim.status
            == status_filter,
        )

    return (
        claims_query
        .order_by(
            AttendanceClaim.id.desc(),
        )
        .all()
    )


@router.get(
    "/claims/{claim_id}",
    response_model=ClaimDetailResponse,
)
def get_faculty_claim_detail(
    claim_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    claim = ensure_faculty_owns_claim(
        db=db,
        faculty_id=current_user.id,
        claim_id=claim_id,
    )

    return claim


@router.post(
    "/claims/{claim_id}/approve",
)
def approve_claim(
    claim_id: int,
    data: ClaimResolutionRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    claim = ensure_faculty_owns_claim(
        db=db,
        faculty_id=current_user.id,
        claim_id=claim_id,
    )

    attendance = (
        db.query(AttendanceAttempt)
        .filter(
            AttendanceAttempt.id == claim.attendance_id,
        )
        .first()
    )

    if not attendance:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Attendance not found",
        )

    if claim.status != ClaimStatus.PENDING:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Claim already resolved",
        )

    if attendance.status != AttendanceStatus.REJECTED:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Attendance is not in rejected state",
        )

    try:
        claim.status = ClaimStatus.APPROVED

        claim.claim_resolved_by = current_user.id

        claim.claim_resolved_at = datetime.now(
            timezone.utc,
        )

        claim.claim_resolution_reason = (
            data.resolution_reason
        )

        attendance.status = AttendanceStatus.CONFIRMED

        attendance.reviewed_by = current_user.id

        attendance.reviewed_at = datetime.now(
            timezone.utc,
        )

        attendance.resolution_reason = (
            data.resolution_reason
        )

        log = FacultyActionLog(
            faculty_id=current_user.id,
            attendance_id=attendance.id,
            claim_id=claim.id,
            original_status=AttendanceStatus.REJECTED.value,
            new_status=AttendanceStatus.CONFIRMED.value,
            resolution_type="CLAIM_APPROVED",
            reason=data.resolution_reason,
        )

        db.add(log)

        db.commit()

    except Exception:
        db.rollback()
        raise

    return {"status": "approved"}


@router.post(
    "/claims/{claim_id}/reject",
)
def reject_claim(
    claim_id: int,
    data: ClaimResolutionRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    claim = ensure_faculty_owns_claim(
        db=db,
        faculty_id=current_user.id,
        claim_id=claim_id,
    )

    attendance = (
        db.query(AttendanceAttempt)
        .filter(
            AttendanceAttempt.id == claim.attendance_id,
        )
        .first()
    )

    if not attendance:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Attendance not found",
        )

    if claim.status != ClaimStatus.PENDING:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Claim already resolved",
        )

    if attendance.status != AttendanceStatus.REJECTED:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Attendance is not in rejected state",
        )

    try:
        claim.status = ClaimStatus.REJECTED

        claim.claim_resolved_by = current_user.id

        claim.claim_resolved_at = datetime.now(
            timezone.utc,
        )

        claim.claim_resolution_reason = (
            data.resolution_reason
        )

        log = FacultyActionLog(
            faculty_id=current_user.id,
            attendance_id=attendance.id,
            claim_id=claim.id,
            original_status=AttendanceStatus.REJECTED.value,
            new_status=AttendanceStatus.REJECTED.value,
            resolution_type="CLAIM_REJECTED",
            reason=data.resolution_reason,
        )

        db.add(log)

        db.commit()

    except Exception:
        db.rollback()
        raise

    return {"status": "rejected"}


@router.get(
    "/student/{student_id}/history",
    response_model=list[StudentHistoryItem],
)
def get_student_history(
    student_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):

    history_records = (
        db.query(
            AttendanceAttempt,
            Course.course_name,
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
        .join(
            FacultyCourse,
            FacultyCourse.course_id
            == Course.id,
        )
        .filter(
            AttendanceAttempt.student_id
            == student_id,
            FacultyCourse.faculty_id
            == current_user.id,
        )
        .order_by(
            AttendanceAttempt.id.desc(),
        )
        .all()
    )

    if not history_records:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student history not found",
        )

    return [
        {
            "attendance_id": attendance.id,
            "course_name": course_name,
            "status": attendance.status.value,
            "timestamp": (
                # NOTE: AttendanceAttempt has no created_at column, so
                # we fall back to the current time instead of crashing
                # with AttributeError when reviewed_at is unset.
                attendance.reviewed_at
                or datetime.now(timezone.utc)
            ),
        }
        for (
            attendance,
            course_name,
        ) in history_records
    ]

################################################################################
# END FILE: backend/app/api/v1/faculty.py
################################################################################