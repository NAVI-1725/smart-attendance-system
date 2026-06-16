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
from app.db.session import get_db
from app.models.course import Course
from app.models.course_registration_session import CourseRegistrationSession
from app.models.enrollment import Enrollment
from app.models.faculty_course import FacultyCourse
from app.models.user import User
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

    session = CourseRegistrationSession(
        course_id=data.course_id,
        faculty_id=current_user.id,
        is_active=True,
    )

    db.add(session)
    db.commit()
    db.refresh(session)

    return {
        "id": session.id,
        "course_id": course.id,
        "course_code": course.course_code,
        "course_name": course.course_name,
        "faculty_id": session.faculty_id,
        "is_active": session.is_active,
    }


@router.get(
    "/open",
    response_model=list[RegistrationSessionResponse],
)
def get_open_registration_sessions(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
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
        .filter(
            CourseRegistrationSession.id == session_id,
        )
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
            detail="Student is already enrolled in this course",
        )

    enrollment = Enrollment(
        student_id=current_user.id,
        course_id=reg_session.course_id,
    )

    db.add(enrollment)
    db.commit()

    return {"message": "Enrollment successful"}


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

    reg_session = (
        db.query(CourseRegistrationSession)
        .filter(
            CourseRegistrationSession.id == session_id,
        )
        .first()
    )

    if not reg_session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Registration session not found",
        )

    if reg_session.faculty_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Faculty does not own this registration session",
        )

    reg_session.is_active = False
    reg_session.closed_at = datetime.now(timezone.utc)

    db.commit()

    return {"message": "Registration session closed"}