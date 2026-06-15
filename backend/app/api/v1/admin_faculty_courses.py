# backend/app/api/v1/admin_faculty_courses.py

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
from app.models.faculty_course import FacultyCourse
from app.models.user import User
from app.schemas.admin_faculty_course import (
    FacultyCourseCreate,
    FacultyCourseResponse,
)

router = APIRouter(
    prefix="/admin/faculty-course",
    tags=["Admin Faculty Course"],
    dependencies=[Depends(require_admin)],
)


@router.post(
    "",
    response_model=FacultyCourseResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_faculty_course_assignment(
    data: FacultyCourseCreate,
    db: Session = Depends(get_db),
):
    faculty = (
        db.query(User)
        .filter(
            User.id == data.faculty_id,
        )
        .first()
    )

    if not faculty:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Faculty not found",
        )

    if faculty.role.lower() != "faculty":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User is not a faculty member",
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

    existing_assignment = (
        db.query(FacultyCourse)
        .filter(
            FacultyCourse.faculty_id == data.faculty_id,
            FacultyCourse.course_id == data.course_id,
        )
        .first()
    )

    if existing_assignment:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Faculty is already assigned to this course",
        )

    assignment = FacultyCourse(
        faculty_id=data.faculty_id,
        course_id=data.course_id,
    )

    db.add(assignment)
    db.commit()
    db.refresh(assignment)

    return {
        "id": assignment.id,
        "faculty_id": faculty.id,
        "faculty_name": faculty.full_name,
        "course_id": course.id,
        "course_code": course.course_code,
        "course_name": course.course_name,
    }


@router.get(
    "",
    response_model=list[FacultyCourseResponse],
)
def get_faculty_course_assignments(
    db: Session = Depends(get_db),
):
    assignments = (
        db.query(
            FacultyCourse,
            User,
            Course,
        )
        .join(
            User,
            FacultyCourse.faculty_id == User.id,
        )
        .join(
            Course,
            FacultyCourse.course_id == Course.id,
        )
        .order_by(
            FacultyCourse.id.asc(),
        )
        .all()
    )

    return [
        {
            "id": assignment.id,
            "faculty_id": faculty.id,
            "faculty_name": faculty.full_name,
            "course_id": course.id,
            "course_code": course.course_code,
            "course_name": course.course_name,
        }
        for (
            assignment,
            faculty,
            course,
        ) in assignments
    ]


@router.delete(
    "/{assignment_id}",
    status_code=status.HTTP_200_OK,
)
def delete_faculty_course_assignment(
    assignment_id: int,
    db: Session = Depends(get_db),
):
    assignment = (
        db.query(FacultyCourse)
        .filter(
            FacultyCourse.id == assignment_id,
        )
        .first()
    )

    if not assignment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Assignment not found",
        )

    db.delete(assignment)
    db.commit()

    return {
        "message": "Assignment deleted successfully",
    }