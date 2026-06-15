# backend/app/api/v1/admin_courses.py

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
from app.schemas.admin_course import (
    CourseCreate,
    CourseUpdate,
    CourseResponse,
)

router = APIRouter(
    prefix="/admin/courses",
    tags=["Admin Courses"],
    dependencies=[Depends(require_admin)],
)


@router.post(
    "",
    response_model=CourseResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_course(
    data: CourseCreate,
    db: Session = Depends(get_db),
):
    course_code = data.course_code.strip().upper()
    course_name = data.course_name.strip()

    existing_course = (
        db.query(Course)
        .filter(
            Course.course_code == course_code,
        )
        .first()
    )

    if existing_course:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Course code already exists",
        )

    course = Course(
        course_code=course_code,
        course_name=course_name,
    )

    db.add(course)
    db.commit()
    db.refresh(course)

    return course


@router.get(
    "",
    response_model=list[CourseResponse],
)
def get_courses(
    db: Session = Depends(get_db),
):
    return (
        db.query(Course)
        .order_by(Course.id.asc())
        .all()
    )


@router.get(
    "/{course_id}",
    response_model=CourseResponse,
)
def get_course(
    course_id: int,
    db: Session = Depends(get_db),
):
    course = (
        db.query(Course)
        .filter(
            Course.id == course_id,
        )
        .first()
    )

    if not course:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Course not found",
        )

    return course


@router.put(
    "/{course_id}",
    response_model=CourseResponse,
)
def update_course(
    course_id: int,
    data: CourseUpdate,
    db: Session = Depends(get_db),
):
    course = (
        db.query(Course)
        .filter(
            Course.id == course_id,
        )
        .first()
    )

    if not course:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Course not found",
        )

    course_code = data.course_code.strip().upper()
    course_name = data.course_name.strip()

    duplicate_course = (
        db.query(Course)
        .filter(
            Course.course_code == course_code,
            Course.id != course_id,
        )
        .first()
    )

    if duplicate_course:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Course code already exists",
        )

    course.course_code = course_code
    course.course_name = course_name

    db.commit()
    db.refresh(course)

    return course


@router.delete(
    "/{course_id}",
    status_code=status.HTTP_200_OK,
)
def delete_course(
    course_id: int,
    db: Session = Depends(get_db),
):
    course = (
        db.query(Course)
        .filter(
            Course.id == course_id,
        )
        .first()
    )

    if not course:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Course not found",
        )

    db.delete(course)
    db.commit()

    return {
        "message": "Course deleted successfully",
    }