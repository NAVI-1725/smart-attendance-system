# backend/app/api/v1/admin_faculty.py

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
from app.schemas.admin_faculty import (
    FacultyCreate,
    FacultyUpdate,
    FacultyResponse,
)

router = APIRouter(
    prefix="/admin/faculty",
    tags=["Admin Faculty"],
    dependencies=[Depends(require_admin)],
)


@router.post(
    "",
    response_model=FacultyResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_faculty(
    data: FacultyCreate,
    db: Session = Depends(get_db),
):
    email = data.email.lower().strip()

    existing_faculty = (
        db.query(User)
        .filter(
            User.email == email,
        )
        .first()
    )

    if existing_faculty:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email already exists",
        )

    faculty = User(
        full_name=data.full_name.strip(),
        email=email,
        password_hash=get_password_hash(
            data.password,
        ),
        role=UserRole.FACULTY.value,
        is_active=True,
    )

    db.add(faculty)
    db.commit()
    db.refresh(faculty)

    return faculty


@router.get(
    "",
    response_model=list[FacultyResponse],
)
def get_faculty(
    db: Session = Depends(get_db),
):
    faculty = (
        db.query(User)
        .filter(
            User.role == UserRole.FACULTY.value,
        )
        .order_by(
            User.id.asc(),
        )
        .all()
    )

    return faculty


@router.get(
    "/{faculty_id}",
    response_model=FacultyResponse,
)
def get_faculty_member(
    faculty_id: int,
    db: Session = Depends(get_db),
):
    faculty = (
        db.query(User)
        .filter(
            User.id == faculty_id,
            User.role == UserRole.FACULTY.value,
        )
        .first()
    )

    if not faculty:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Faculty not found",
        )

    return faculty


@router.put(
    "/{faculty_id}",
    response_model=FacultyResponse,
)
def update_faculty(
    faculty_id: int,
    data: FacultyUpdate,
    db: Session = Depends(get_db),
):
    faculty = (
        db.query(User)
        .filter(
            User.id == faculty_id,
            User.role == UserRole.FACULTY.value,
        )
        .first()
    )

    if not faculty:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Faculty not found",
        )

    email = data.email.lower().strip()

    existing_faculty = (
        db.query(User)
        .filter(
            User.email == email,
            User.id != faculty_id,
        )
        .first()
    )

    if existing_faculty:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email already exists",
        )

    faculty.full_name = data.full_name.strip()
    faculty.email = email
    faculty.is_active = data.is_active

    db.commit()
    db.refresh(faculty)

    return faculty


@router.delete(
    "/{faculty_id}",
    status_code=status.HTTP_200_OK,
)
def delete_faculty(
    faculty_id: int,
    db: Session = Depends(get_db),
):
    faculty = (
        db.query(User)
        .filter(
            User.id == faculty_id,
            User.role == UserRole.FACULTY.value,
        )
        .first()
    )

    if not faculty:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Faculty not found",
        )

    db.delete(faculty)
    db.commit()

    return {
        "message": "Faculty deleted successfully",
    }