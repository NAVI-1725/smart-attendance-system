# backend/app/api/v1/attendance.py

from datetime import datetime, timezone

from fastapi import APIRouter, Depends
import logging
from sqlalchemy.orm import Session as DBSession
from sqlalchemy.exc import IntegrityError

from app.db.session import get_db
from app.core.auth import get_current_user
from app.core.dependencies import require_faculty
from app.core.domain_rules import (
    ensure_student_enrolled_in_course,
)
from app.core.errors import ApiError, ErrorCode
from app.core.constants.roles import UserRole
from app.models.user import User
from app.models.attendance_session import AttendanceSession
from app.models.attendance import AttendanceAttempt
from app.models.attendance_ble_evidence import AttendanceBleEvidence
from app.models.attendance_gps_evidence import AttendanceGpsEvidence
from app.models.attendance_ble_nonce import AttendanceBLENonce
from app.models.course import Course
from app.models.attendance_claim import AttendanceClaim
from app.models.enums import (
    AttendanceStatus,
    AttendanceSessionStatus,
    AttendanceEvidenceResult,
)
from app.schemas.attendance import (
    AttendanceAttemptRequest,
    AttendanceJoinResponse,
    AttendanceSubmitResponse,
    CloseAttendanceResponse,
    AttendanceEvidenceResponse,
    AttendanceSnapshotResponse,
    BleEvidenceSnapshotResponse,
    GpsEvidenceSnapshotResponse,
    AttendanceHistoryItem,
)
from app.services.ble_security_service import (
    validate_ble_attendance,
)
from app.services.gps_service import (
    validate_location,
)
from app.services.attendance_evidence_service import (
    evaluate_evidence,
)
from app.services.session_cleanup_service import (
    deactivate_expired_sessions,
)

router = APIRouter(tags=["Attendance"])
logger = logging.getLogger(__name__)


@router.post(
    "/attempt",
    response_model=AttendanceSubmitResponse,
)
def submit_attendance(
    data: AttendanceAttemptRequest,
    db: DBSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    deactivate_expired_sessions(db)

    now = datetime.now(timezone.utc)

    try:
        session_id = int(data.session_id)
    except (TypeError, ValueError):
        raise ApiError(
            ErrorCode.INVALID_SESSION,
            "Invalid attendance session",
            status_code=400,
        )

    session = (
        db.query(AttendanceSession)
        .filter(
            AttendanceSession.id == session_id,
        )
        .with_for_update()
        .first()
    )

    if not session:
        raise ApiError(
            ErrorCode.INVALID_SESSION,
            "Attendance session not found",
            status_code=404,
        )

    if session.closed_at is not None:
        raise ApiError(
            ErrorCode.SESSION_CLOSED,
            "Attendance session is closed",
            status_code=403,
        )

    if session.expires_at <= now:
        raise ApiError(
            ErrorCode.SESSION_EXPIRED,
            "Attendance session expired",
            status_code=403,
        )

    if not session.is_active:
        raise ApiError(
            ErrorCode.SESSION_CLOSED,
            "Attendance session inactive",
            status_code=403,
        )

    logger.info(
        "BLE evidence received",
        extra={"ble": data.ble_evidence},
    )
    print("SESSION ID =", session.id)
    print("CLASSROOM ID =", session.classroom_id)
    print("BLE PAYLOAD =", data.ble_evidence)

    ble_status = validate_ble_attendance(
        db=db,
        session_id=session.id,
        classroom_id=session.classroom_id,
        ble=data.ble_evidence,
    )
    print("BLE STATUS =", ble_status)

    gps_result, distance_meters, validation_reason = (
        validate_location(
            classroom=session.classroom,
            latitude=data.gps_evidence.latitude,
            longitude=data.gps_evidence.longitude,
            accuracy_meters=data.gps_evidence.accuracy_meters,
            captured_at=data.gps_evidence.captured_at,
        )
    )

    evidence_result = evaluate_evidence(
        ble_result=ble_status,
        gps_result=gps_result,
    )

    attendance_status = (
        AttendanceStatus.CONFIRMED
        if evidence_result
        == AttendanceEvidenceResult.CONFIRMED
        else AttendanceStatus.FLAGGED
    )

    try:

        attendance = AttendanceAttempt(
            student_id=current_user.id,
            classroom_id=session.classroom_id,
            session_id=session.id,
            status=attendance_status,
        )

        db.add(attendance)
        db.flush()

        for _, beacon in data.ble_evidence.per_beacon.items():

            nonce_record = AttendanceBLENonce(
                session_id=session.id,
                nonce=beacon.nonce,
            )

            db.add(nonce_record)

        if data.ble_evidence is not None:

            ble_row = AttendanceBleEvidence(
                attendance_id=attendance.id,
                ble_payload=data.ble_evidence.dict(),
                client_timestamp=(
                    data.gps_evidence.captured_at
                ),
                server_received_timestamp=(
                    datetime.now(timezone.utc)
                ),
            )

            db.add(ble_row)

        gps_row = AttendanceGpsEvidence(
            attendance_id=attendance.id,
            latitude=data.gps_evidence.latitude,
            longitude=data.gps_evidence.longitude,
            accuracy_meters=data.gps_evidence.accuracy_meters,
            captured_at=data.gps_evidence.captured_at,
            distance_from_classroom_meters=distance_meters,
            validation_result=gps_result,
            validation_reason=validation_reason,
        )

        db.add(gps_row)

        db.commit()

        db.refresh(attendance)

    except IntegrityError as e:

        db.rollback()

        print("INTEGRITY ERROR =", e)

        raise ApiError(
            ErrorCode.DUPLICATE_ATTENDANCE,
            "Attendance already recorded",
            status_code=409,
        )

    except Exception:

        db.rollback()
        raise

    response = {
        "attempt_id": str(attendance.id),
        "session_id": str(session.id),
        "student_id": str(current_user.id),
        "timestamp": datetime.now(
            timezone.utc,
        ).isoformat(),
        "status": attendance.status.value,
        "is_flagged": (
            attendance.status
            == AttendanceStatus.FLAGGED
        ),
    }

    print("ATTENDANCE RESPONSE =", response)

    return response


@router.post(
    "/join",
    response_model=AttendanceJoinResponse,
)
def join_attendance(
    classroom_id: int,
    db: DBSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    if current_user.role != UserRole.STUDENT.value:
        raise ApiError(
            ErrorCode.NOT_AUTHORIZED,
            "Only students may join attendance",
            status_code=403,
        )

    deactivate_expired_sessions(db)

    now = datetime.now(timezone.utc)

    faculty_session = (
        db.query(AttendanceSession)
        .filter(
            AttendanceSession.classroom_id == classroom_id,
            AttendanceSession.is_active == True,
            AttendanceSession.closed_at.is_(None),
            AttendanceSession.expires_at > now,
        )
        .with_for_update()
        .first()
    )

    if not faculty_session:
        raise ApiError(
            ErrorCode.CLASS_NOT_ACTIVE,
            "No active classroom",
            status_code=404,
        )

    ensure_student_enrolled_in_course(
        db,
        current_user.id,
        faculty_session.course_id,
    )

    # Student authentication is already validated via JWT + get_current_user

    existing = (
        db.query(AttendanceAttempt)
        .filter(
            AttendanceAttempt.student_id == current_user.id,
            AttendanceAttempt.session_id == faculty_session.id,
        )
        .first()
    )

    if existing:
        raise ApiError(
            ErrorCode.DUPLICATE_ATTENDANCE,
            "Attendance already recorded",
            status_code=409,
        )

    attendance = AttendanceAttempt(
        student_id=current_user.id,
        classroom_id=classroom_id,
        session_id=faculty_session.id,
        status=AttendanceStatus.CONFIRMED,
    )

    db.add(attendance)

    try:
        db.commit()
    except IntegrityError:
        db.rollback()

        raise ApiError(
            ErrorCode.DUPLICATE_ATTENDANCE,
            "Attendance already recorded",
            status_code=409,
        )

    return {"status": "present"}


@router.get("/classroom/{classroom_id}", dependencies=[Depends(require_faculty)])
def get_classroom_attendance(
    classroom_id: int,
    db: DBSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    records = (
        db.query(AttendanceAttempt, User.full_name, User.email)
        .join(User, AttendanceAttempt.student_id == User.id)
        .filter(AttendanceAttempt.classroom_id == classroom_id)
        .all()
    )

    return [
        {
            "student_name": name,
            "student_email": email,
            "status": attendance.status,
        }
        for attendance, name, email in records
    ]


@router.get(
    "/my-history",
    response_model=list[AttendanceHistoryItem],
)
def get_my_attendance_history(
    db: DBSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    records = (
        db.query(
            AttendanceAttempt,
            AttendanceSession,
            Course,
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
            AttendanceAttempt.student_id
            == current_user.id,
        )
        .order_by(
            AttendanceAttempt.id.desc(),
        )
        .all()
    )

    history_items = []

    for attendance, session, course in records:

        has_claim = (
            db.query(AttendanceClaim)
            .filter(
                AttendanceClaim.attendance_id
                == attendance.id
            )
            .first()
            is not None
        )

        history_items.append(
            AttendanceHistoryItem(
                attendance_id=attendance.id,
                course_code=course.course_code,
                course_name=course.course_name,
                status=attendance.status.value,
                timestamp=session.started_at,
                has_claim=has_claim,
            )
        )

    return history_items


@router.post(
    "/close/{classroom_id}",
    response_model=CloseAttendanceResponse,
    dependencies=[Depends(require_faculty)],
)
def close_attendance(
    classroom_id: int,
    db: DBSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    deactivate_expired_sessions(db)

    now = datetime.now(timezone.utc)

    faculty_session = (
        db.query(AttendanceSession)
        .filter(
            AttendanceSession.classroom_id == classroom_id,
            AttendanceSession.is_active == True,
            AttendanceSession.closed_at.is_(None),
            AttendanceSession.expires_at > now,
        )
        .with_for_update()
        .first()
    )

    if not faculty_session:
        raise ApiError(
            ErrorCode.CLASS_NOT_ACTIVE,
            "No active classroom",
            status_code=404,
        )

    faculty_session.is_active = False
    faculty_session.closed_at = datetime.now(timezone.utc)
    faculty_session.status = AttendanceSessionStatus.CLOSED

    db.commit()

    return {
        "status": "closed",
        "classroom_id": classroom_id,
        "session_id": faculty_session.id,
        "closed_at": faculty_session.closed_at,
    }


@router.get(
    "/{attendance_id}/evidence",
    response_model=AttendanceEvidenceResponse,
    dependencies=[Depends(require_faculty)],
)
def get_attendance_evidence(
    attendance_id: int,
    db: DBSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    attendance = (
        db.query(AttendanceAttempt)
        .filter(
            AttendanceAttempt.id == attendance_id,
        )
        .first()
    )

    if not attendance:
        raise ApiError(
            ErrorCode.NOT_FOUND,
            "Attendance record not found",
            status_code=404,
        )

    ble_evidence = (
        db.query(AttendanceBleEvidence)
        .filter(
            AttendanceBleEvidence.attendance_id
            == attendance.id
        )
        .first()
    )

    gps_evidence = (
        db.query(AttendanceGpsEvidence)
        .filter(
            AttendanceGpsEvidence.attendance_id
            == attendance.id
        )
        .first()
    )

    return AttendanceEvidenceResponse(
        attendance=AttendanceSnapshotResponse(
            id=attendance.id,
            student_id=attendance.student_id,
            classroom_id=attendance.classroom_id,
            session_id=attendance.session_id,
            status=attendance.status.value,
        ),
        ble_evidence=(
            BleEvidenceSnapshotResponse(
                attendance_id=ble_evidence.attendance_id,
                ble_payload=ble_evidence.ble_payload,
                created_at=ble_evidence.created_at,
            )
            if ble_evidence
            else None
        ),
        gps_evidence=(
            GpsEvidenceSnapshotResponse(
                attendance_id=gps_evidence.attendance_id,
                latitude=gps_evidence.latitude,
                longitude=gps_evidence.longitude,
                accuracy_meters=gps_evidence.accuracy_meters,
                captured_at=gps_evidence.captured_at,
                distance_from_classroom_meters=(
                    gps_evidence.distance_from_classroom_meters
                ),
                validation_result=(
                    gps_evidence.validation_result.value
                    if gps_evidence.validation_result
                    else None
                ),
                validation_reason=gps_evidence.validation_reason,
                created_at=gps_evidence.created_at,
            )
            if gps_evidence
            else None
        ),
    )