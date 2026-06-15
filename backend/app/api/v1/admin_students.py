# backend/app/api/v1/admin_students.py

from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    status,
)
from sqlalchemy.orm import Session

from app.core.constants.roles import UserRole
from app.core.dependencies import require_admin
from app.core.security import get_password_hash
from app.db.session import get_db
from app.models.user import User
from app.schemas.admin_student import (
    StudentCreate,
    StudentUpdate,
    StudentResponse,
)

router = APIRouter(
    prefix="/admin/students",
    tags=["Admin Students"],
    dependencies=[Depends(require_admin)],
)


@router.post(
    "",
    response_model=StudentResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_student(
    data: StudentCreate,
    db: Session = Depends(get_db),
):
    email = data.email.lower().strip()

    existing_student = (
        db.query(User)
        .filter(
            User.email == email,
        )
        .first()
    )

    if existing_student:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email already exists",
        )

    student = User(
        full_name=data.full_name.strip(),
        email=email,
        password_hash=get_password_hash(
            data.password,
        ),
        role=UserRole.STUDENT.value,
        is_active=True,
    )

    db.add(student)
    db.commit()
    db.refresh(student)

    return student


@router.get(
    "",
    response_model=list[StudentResponse],
)
def get_students(
    db: Session = Depends(get_db),
):
    students = (
        db.query(User)
        .filter(
            User.role == "student",
        )
        .order_by(
            User.id.asc(),
        )
        .all()
    )

    return students


@router.get(
    "/{student_id}",
    response_model=StudentResponse,
)
def get_student(
    student_id: int,
    db: Session = Depends(get_db),
):
    student = (
        db.query(User)
        .filter(
            User.id == student_id,
            User.role == "student",
        )
        .first()
    )

    if not student:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student not found",
        )

    return student


@router.put(
    "/{student_id}",
    response_model=StudentResponse,
)
def update_student(
    student_id: int,
    data: StudentUpdate,
    db: Session = Depends(get_db),
):
    student = (
        db.query(User)
        .filter(
            User.id == student_id,
            User.role == "student",
        )
        .first()
    )

    if not student:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student not found",
        )

    email = data.email.lower().strip()

    existing_student = (
        db.query(User)
        .filter(
            User.email == email,
            User.id != student_id,
        )
        .first()
    )

    if existing_student:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email already exists",
        )

    student.full_name = data.full_name.strip()
    student.email = email
    student.is_active = data.is_active

    db.commit()
    db.refresh(student)

    return student


@router.delete(
    "/{student_id}",
    status_code=status.HTTP_200_OK,
)
def delete_student(
    student_id: int,
    db: Session = Depends(get_db),
):
    student = (
        db.query(User)
        .filter(
            User.id == student_id,
            User.role == "student",
        )
        .first()
    )

    if not student:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student not found",
        )

    db.delete(student)
    db.commit()

    return {
        "message": "Student deleted successfully",
    }