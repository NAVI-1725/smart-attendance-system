# backend/app/api/v1/claims.py

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from sqlalchemy import func

from app.core.dependencies import (
    get_current_user,
)
from app.db.session import get_db
from app.core.errors import (
    ApiError,
    ErrorCode,
)
from app.core.domain_rules import (
    ensure_student_owns_attendance,
)
from app.models.user import User
from app.models.attendance import AttendanceAttempt
from app.models.attendance_claim import AttendanceClaim
from app.models.enums import (
    AttendanceStatus,
    ClaimStatus,
)
from app.schemas.claim import (
    ClaimCreateRequest,
    ClaimResponse,
    ClaimDetailResponse,
    ClaimStatisticsResponse,
)

router = APIRouter(
    tags=["Claims"],
)


@router.post(
    "",
    response_model=ClaimResponse,
)
def create_claim(
    data: ClaimCreateRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    attendance = ensure_student_owns_attendance(
        db=db,
        student_id=current_user.id,
        attendance_id=data.attendance_id,
    )

    if attendance.status not in (
        AttendanceStatus.REJECTED,
        AttendanceStatus.FLAGGED,
    ):
        raise ApiError(
            ErrorCode.NOT_AUTHORIZED,
            "Claims are only allowed for rejected or flagged attendance",
            status_code=400,
        )

    existing_claim = (
        db.query(AttendanceClaim)
        .filter(
            AttendanceClaim.attendance_id == attendance.id,
        )
        .first()
    )

    if existing_claim:
        raise ApiError(
            ErrorCode.NOT_AUTHORIZED,
            "Claim already exists for this attendance",
            status_code=409,
        )

    claim = AttendanceClaim(
        attendance_id=attendance.id,
        student_id=current_user.id,
        original_attendance_status=attendance.status,
        reason=data.reason,
        status=ClaimStatus.PENDING,
    )

    db.add(claim)

    try:
        db.commit()
        db.refresh(claim)

    except IntegrityError:
        db.rollback()

        raise ApiError(
            ErrorCode.NOT_AUTHORIZED,
            "Claim already exists for this attendance",
            status_code=409,
        )

    return claim


@router.get(
    "/mine",
    response_model=list[ClaimResponse],
)
def get_my_claims(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    claims = (
        db.query(AttendanceClaim)
        .filter(
            AttendanceClaim.student_id == current_user.id,
        )
        .order_by(
            AttendanceClaim.id.desc(),
        )
        .all()
    )

    return claims


@router.get(
    "/statistics",
    response_model=ClaimStatisticsResponse,
)
def get_claim_statistics(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    total = (
        db.query(func.count(AttendanceClaim.id))
        .filter(
            AttendanceClaim.student_id == current_user.id,
        )
        .scalar()
    )

    pending = (
        db.query(func.count(AttendanceClaim.id))
        .filter(
            AttendanceClaim.student_id == current_user.id,
            AttendanceClaim.status == ClaimStatus.PENDING,
        )
        .scalar()
    )

    approved = (
        db.query(func.count(AttendanceClaim.id))
        .filter(
            AttendanceClaim.student_id == current_user.id,
            AttendanceClaim.status == ClaimStatus.APPROVED,
        )
        .scalar()
    )

    rejected = (
        db.query(func.count(AttendanceClaim.id))
        .filter(
            AttendanceClaim.student_id == current_user.id,
            AttendanceClaim.status == ClaimStatus.REJECTED,
        )
        .scalar()
    )

    return {
        "total": total,
        "pending": pending,
        "approved": approved,
        "rejected": rejected,
    }


@router.get(
    "/{claim_id}",
    response_model=ClaimDetailResponse,
)
def get_claim_detail(
    claim_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    claim = (
        db.query(AttendanceClaim)
        .filter(
            AttendanceClaim.id == claim_id,
        )
        .first()
    )

    if not claim:
        raise ApiError(
            ErrorCode.NOT_FOUND,
            "Claim not found",
            status_code=404,
        )

    if claim.student_id != current_user.id:
        raise ApiError(
            ErrorCode.NOT_AUTHORIZED,
            "Claim does not belong to student",
            status_code=403,
        )

    return claim