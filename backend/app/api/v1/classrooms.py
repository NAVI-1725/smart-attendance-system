# backend/app/api/v1/classrooms.py

from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    status,
)
from sqlalchemy.orm import Session

from app.core.dependencies import (
    require_faculty,
    require_admin_or_faculty,
)
from app.db.session import get_db
from app.models.classroom import Classroom
from app.schemas.classroom import (
    ClassroomCreate,
    ClassroomResponse,
    ClassroomUpdate,
)

router = APIRouter(
    prefix="/classrooms",
    tags=["Classrooms"],
    dependencies=[
        Depends(require_admin_or_faculty)
    ],
)


@router.post(
    "",
    response_model=ClassroomResponse,
)
def create_classroom(
    data: ClassroomCreate,
    db: Session = Depends(get_db),
    current_user=Depends(
        require_faculty,
    ),
):
    classroom = Classroom(
        name=data.name.strip(),
        faculty_id=current_user.id,
        latitude=data.latitude,
        longitude=data.longitude,
        gps_radius_meters=data.gps_radius_meters,
    )

    db.add(classroom)
    db.commit()
    db.refresh(classroom)

    return classroom


@router.get(
    "",
    response_model=list[ClassroomResponse],
)
def get_classrooms(
    db: Session = Depends(get_db),
    current_user=Depends(
        require_admin_or_faculty,
    ),
):
    if current_user.role == "admin":
        classrooms = (
            db.query(Classroom)
            .order_by(Classroom.id.asc())
            .all()
        )
    else:
        classrooms = (
            db.query(Classroom)
            .filter(
                Classroom.faculty_id == current_user.id,
            )
            .order_by(Classroom.id.asc())
            .all()
        )

    return classrooms


@router.get(
    "/{classroom_id}",
    response_model=ClassroomResponse,
)
def get_classroom(
    classroom_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(
        require_admin_or_faculty,
    ),
):
    if current_user.role == "admin":
        classroom = (
            db.query(Classroom)
            .filter(
                Classroom.id == classroom_id,
            )
            .first()
        )
    else:
        classroom = (
            db.query(Classroom)
            .filter(
                Classroom.id == classroom_id,
                Classroom.faculty_id == current_user.id,
            )
            .first()
        )

    if not classroom:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Classroom not found",
        )

    return classroom


@router.put(
    "/{classroom_id}",
    response_model=ClassroomResponse,
)
def update_classroom(
    classroom_id: int,
    data: ClassroomUpdate,
    db: Session = Depends(get_db),
    current_user=Depends(
        require_admin_or_faculty,
    ),
):
    if current_user.role == "admin":
        classroom = (
            db.query(Classroom)
            .filter(
                Classroom.id == classroom_id,
            )
            .first()
        )
    else:
        classroom = (
            db.query(Classroom)
            .filter(
                Classroom.id == classroom_id,
                Classroom.faculty_id == current_user.id,
            )
            .first()
        )

    if not classroom:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Classroom not found",
        )

    classroom.name = data.name.strip()
    classroom.latitude = data.latitude
    classroom.longitude = data.longitude
    classroom.gps_radius_meters = data.gps_radius_meters

    db.commit()
    db.refresh(classroom)

    return classroom


@router.delete(
    "/{classroom_id}",
    status_code=status.HTTP_200_OK,
)
def delete_classroom(
    classroom_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(
        require_admin_or_faculty,
    ),
):
    if current_user.role == "admin":
        classroom = (
            db.query(Classroom)
            .filter(
                Classroom.id == classroom_id,
            )
            .first()
        )
    else:
        classroom = (
            db.query(Classroom)
            .filter(
                Classroom.id == classroom_id,
                Classroom.faculty_id == current_user.id,
            )
            .first()
        )

    if not classroom:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Classroom not found",
        )

    db.delete(classroom)
    db.commit()

    return {
        "message": "Classroom deleted successfully",
    }