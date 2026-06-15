# backend/app/api/v1/admin_enrollments.py

from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    status,
)
from sqlalchemy.orm import Session

from app.core.dependencies import require_admin
from app.db.session import get_db
from app.models.course import Course
from app.models.enrollment import Enrollment
from app.models.user import User
from app.schemas.admin_enrollment import (
    EnrollmentCreate,
    EnrollmentResponse,
)

router = APIRouter(
    prefix="/admin/enrollments",
    tags=["Admin Enrollments"],
    dependencies=[Depends(require_admin)],
)


@router.post(
    "",
    response_model=EnrollmentResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_enrollment(
    data: EnrollmentCreate,
    db: Session = Depends(get_db),
):
    student = (
        db.query(User)
        .filter(
            User.id == data.student_id,
        )
        .first()
    )

    if not student:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student not found",
        )

    if student.role.lower() != "student":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User is not a student",
        )

    course = (
        db.query(Course)
        .filter(
            Course.id == data.course_id,
        )
        .first()
    )

    if not course:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Course not found",
        )

    existing_enrollment = (
        db.query(Enrollment)
        .filter(
            Enrollment.student_id == data.student_id,
            Enrollment.course_id == data.course_id,
        )
        .first()
    )

    if existing_enrollment:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Student already enrolled",
        )

    enrollment = Enrollment(
        student_id=data.student_id,
        course_id=data.course_id,
    )

    db.add(enrollment)
    db.commit()
    db.refresh(enrollment)

    return {
        "id": enrollment.id,
        "student_id": student.id,
        "student_name": student.full_name,
        "course_id": course.id,
        "course_code": course.course_code,
        "course_name": course.course_name,
    }


@router.get(
    "",
    response_model=list[EnrollmentResponse],
)
def get_enrollments(
    db: Session = Depends(get_db),
):
    enrollments = (
        db.query(
            Enrollment,
            User,
            Course,
        )
        .join(
            User,
            Enrollment.student_id == User.id,
        )
        .join(
            Course,
            Enrollment.course_id == Course.id,
        )
        .order_by(
            Enrollment.id.asc(),
        )
        .all()
    )

    return [
        {
            "id": enrollment.id,
            "student_id": student.id,
            "student_name": student.full_name,
            "course_id": course.id,
            "course_code": course.course_code,
            "course_name": course.course_name,
        }
        for (
            enrollment,
            student,
            course,
        ) in enrollments
    ]


@router.delete(
    "/{enrollment_id}",
    status_code=status.HTTP_200_OK,
)
def delete_enrollment(
    enrollment_id: int,
    db: Session = Depends(get_db),
):
    enrollment = (
        db.query(Enrollment)
        .filter(
            Enrollment.id == enrollment_id,
        )
        .first()
    )

    if not enrollment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Enrollment not found",
        )

    db.delete(enrollment)
    db.commit()

    return {
        "message": "Enrollment deleted successfully",
    }