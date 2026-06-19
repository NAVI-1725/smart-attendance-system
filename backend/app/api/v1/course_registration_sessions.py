# backend/app/api/v1/course_registration_sessions.py

from datetime import datetime, timezone

from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    status,
)
from sqlalchemy.orm import Session

from app.core.dependencies import get_current_user
from app.core.domain_rules import ensure_faculty_owns_registration_session
from app.db.session import get_db
from app.models.course import Course
from app.models.course_registration_request import CourseRegistrationRequest
from app.models.course_registration_session import CourseRegistrationSession
from app.models.enrollment import Enrollment
from app.models.enums import RegistrationRequestStatus
from app.models.faculty_course import FacultyCourse
from app.models.user import User
from app.schemas.course_registration_request import (
    ApproveRequestResponse,
    BulkReviewResponse,
    RegistrationRequestResponse,
    RejectRequestResponse,
)
from app.schemas.course_registration_session import (
    CloseRegistrationResponse,
    JoinRegistrationResponse,
    RegistrationSessionResponse,
    StartRegistrationSessionRequest,
)

router = APIRouter(
    prefix="/registration-sessions",
    tags=["Course Registration Sessions"],
)


@router.post(
    "/start",
    response_model=RegistrationSessionResponse,
    status_code=status.HTTP_201_CREATED,
)
def start_registration_session(
    data: StartRegistrationSessionRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role.lower() != "faculty":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only faculty can start registration sessions",
        )

    course = (
        db.query(Course)
        .filter(Course.id == data.course_id)
        .first()
    )

    if not course:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Course not found",
        )

    faculty_assignment = (
        db.query(FacultyCourse)
        .filter(
            FacultyCourse.faculty_id == current_user.id,
            FacultyCourse.course_id == data.course_id,
        )
        .first()
    )

    if not faculty_assignment:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Faculty is not assigned to this course",
        )

    existing_active_session = (
        db.query(CourseRegistrationSession)
        .filter(
            CourseRegistrationSession.course_id == data.course_id,
            CourseRegistrationSession.is_active == True,
        )
        .first()
    )

    if existing_active_session:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="An active registration session already exists for this course",
        )

    reg_session = CourseRegistrationSession(
        course_id=data.course_id,
        faculty_id=current_user.id,
        is_active=True,
    )

    db.add(reg_session)
    db.commit()
    db.refresh(reg_session)

    return {
        "id": reg_session.id,
        "course_id": course.id,
        "course_code": course.course_code,
        "course_name": course.course_name,
        "faculty_id": reg_session.faculty_id,
        "is_active": reg_session.is_active,
    }


@router.get(
    "/open",
    response_model=list[RegistrationSessionResponse],
)
def get_open_registration_sessions(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role.lower() == "faculty":
        sessions = (
            db.query(
                CourseRegistrationSession,
                Course,
            )
            .join(
                Course,
                CourseRegistrationSession.course_id == Course.id,
            )
            .filter(
                CourseRegistrationSession.is_active == True,
                CourseRegistrationSession.faculty_id == current_user.id,
            )
            .order_by(
                CourseRegistrationSession.id.asc(),
            )
            .all()
        )
    else:
        sessions = (
            db.query(
                CourseRegistrationSession,
                Course,
            )
            .join(
                Course,
                CourseRegistrationSession.course_id == Course.id,
            )
            .filter(
                CourseRegistrationSession.is_active == True,
            )
            .order_by(
                CourseRegistrationSession.id.asc(),
            )
            .all()
        )

    return [
        {
            "id": reg_session.id,
            "course_id": course.id,
            "course_code": course.course_code,
            "course_name": course.course_name,
            "faculty_id": reg_session.faculty_id,
            "is_active": reg_session.is_active,
        }
        for (reg_session, course) in sessions
    ]


@router.post(
    "/{session_id}/join",
    response_model=JoinRegistrationResponse,
    status_code=status.HTTP_201_CREATED,
)
def join_registration_session(
    session_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role.lower() != "student":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only students can join registration sessions",
        )

    reg_session = (
        db.query(CourseRegistrationSession)
        .filter(CourseRegistrationSession.id == session_id)
        .first()
    )

    if not reg_session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Registration session not found",
        )

    if not reg_session.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Registration session is no longer active",
        )

    existing_enrollment = (
        db.query(Enrollment)
        .filter(
            Enrollment.student_id == current_user.id,
            Enrollment.course_id == reg_session.course_id,
        )
        .first()
    )

    if existing_enrollment:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="You are already enrolled in this course",
        )

    existing_request = (
        db.query(CourseRegistrationRequest)
        .filter(
            CourseRegistrationRequest.session_id == session_id,
            CourseRegistrationRequest.student_id == current_user.id,
        )
        .first()
    )

    if existing_request:
        if existing_request.status == RegistrationRequestStatus.PENDING:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="You have already submitted a registration request for this course",
            )
        if existing_request.status == RegistrationRequestStatus.REJECTED:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Your registration request was rejected",
            )
        if existing_request.status == RegistrationRequestStatus.APPROVED:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Your registration request was already approved",
            )

    request = CourseRegistrationRequest(
        session_id=session_id,
        student_id=current_user.id,
        status=RegistrationRequestStatus.PENDING,
    )

    db.add(request)
    db.commit()

    return {"message": "Registration request submitted. Awaiting faculty approval."}


@router.get(
    "/{session_id}/requests",
    response_model=list[RegistrationRequestResponse],
)
def get_registration_requests(
    session_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role.lower() != "faculty":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only faculty can view registration requests",
        )

    ensure_faculty_owns_registration_session(
        db=db,
        faculty_id=current_user.id,
        session_id=session_id,
    )

    rows = (
        db.query(CourseRegistrationRequest, User)
        .join(
            User,
            CourseRegistrationRequest.student_id == User.id,
        )
        .filter(
            CourseRegistrationRequest.session_id == session_id,
        )
        .order_by(CourseRegistrationRequest.id.asc())
        .all()
    )

    return [
        {
            "id": req.id,
            "student_id": req.student_id,
            "student_name": user.full_name,
            "status": req.status,
        }
        for (req, user) in rows
    ]


@router.post(
    "/requests/{request_id}/approve",
    response_model=ApproveRequestResponse,
)
def approve_registration_request(
    request_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role.lower() != "faculty":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only faculty can approve registration requests",
        )

    req = (
        db.query(CourseRegistrationRequest)
        .filter(CourseRegistrationRequest.id == request_id)
        .first()
    )

    if not req:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Registration request not found",
        )

    reg_session = ensure_faculty_owns_registration_session(
        db=db,
        faculty_id=current_user.id,
        session_id=req.session_id,
    )

    if req.status != RegistrationRequestStatus.PENDING:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Request has already been reviewed",
        )

    existing_enrollment = (
        db.query(Enrollment)
        .filter(
            Enrollment.student_id == req.student_id,
            Enrollment.course_id == reg_session.course_id,
        )
        .first()
    )

    if not existing_enrollment:
        enrollment = Enrollment(
            student_id=req.student_id,
            course_id=reg_session.course_id,
        )
        db.add(enrollment)

    req.status = RegistrationRequestStatus.APPROVED
    req.reviewed_at = datetime.now(timezone.utc)
    req.reviewed_by = current_user.id

    db.commit()

    return {"message": "Request approved and student enrolled"}


@router.post(
    "/requests/{request_id}/reject",
    response_model=RejectRequestResponse,
)
def reject_registration_request(
    request_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role.lower() != "faculty":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only faculty can reject registration requests",
        )

    req = (
        db.query(CourseRegistrationRequest)
        .filter(CourseRegistrationRequest.id == request_id)
        .first()
    )

    if not req:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Registration request not found",
        )

    ensure_faculty_owns_registration_session(
        db=db,
        faculty_id=current_user.id,
        session_id=req.session_id,
    )

    if req.status != RegistrationRequestStatus.PENDING:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Request has already been reviewed",
        )

    req.status = RegistrationRequestStatus.REJECTED
    req.reviewed_at = datetime.now(timezone.utc)
    req.reviewed_by = current_user.id

    db.commit()

    return {"message": "Request rejected"}


@router.post(
    "/{session_id}/approve-all",
    response_model=BulkReviewResponse,
)
def approve_all_requests(
    session_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role.lower() != "faculty":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only faculty can approve registration requests",
        )

    reg_session = ensure_faculty_owns_registration_session(
        db=db,
        faculty_id=current_user.id,
        session_id=session_id,
    )

    pending = (
        db.query(CourseRegistrationRequest)
        .filter(
            CourseRegistrationRequest.session_id == session_id,
            CourseRegistrationRequest.status == RegistrationRequestStatus.PENDING,
        )
        .all()
    )

    now = datetime.now(timezone.utc)
    count = 0

    for req in pending:
        existing_enrollment = (
            db.query(Enrollment)
            .filter(
                Enrollment.student_id == req.student_id,
                Enrollment.course_id == reg_session.course_id,
            )
            .first()
        )

        if not existing_enrollment:
            enrollment = Enrollment(
                student_id=req.student_id,
                course_id=reg_session.course_id,
            )
            db.add(enrollment)

        req.status = RegistrationRequestStatus.APPROVED
        req.reviewed_at = now
        req.reviewed_by = current_user.id
        count += 1

    db.commit()

    return {
        "message": f"Approved {count} pending requests",
        "count": count,
    }


@router.post(
    "/{session_id}/reject-all",
    response_model=BulkReviewResponse,
)
def reject_all_requests(
    session_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role.lower() != "faculty":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only faculty can reject registration requests",
        )

    ensure_faculty_owns_registration_session(
        db=db,
        faculty_id=current_user.id,
        session_id=session_id,
    )

    pending = (
        db.query(CourseRegistrationRequest)
        .filter(
            CourseRegistrationRequest.session_id == session_id,
            CourseRegistrationRequest.status == RegistrationRequestStatus.PENDING,
        )
        .all()
    )

    now = datetime.now(timezone.utc)
    count = 0

    for req in pending:
        req.status = RegistrationRequestStatus.REJECTED
        req.reviewed_at = now
        req.reviewed_by = current_user.id
        count += 1

    db.commit()

    return {
        "message": f"Rejected {count} pending requests",
        "count": count,
    }


@router.post(
    "/{session_id}/close",
    response_model=CloseRegistrationResponse,
    status_code=status.HTTP_200_OK,
)
def close_registration_session(
    session_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role.lower() != "faculty":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only faculty can close registration sessions",
        )

    reg_session = ensure_faculty_owns_registration_session(
        db=db,
        faculty_id=current_user.id,
        session_id=session_id,
    )

    reg_session.is_active = False
    reg_session.closed_at = datetime.now(timezone.utc)

    db.commit()

    return {"message": "Registration session closed"}