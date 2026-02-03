# backend\app\api\v1\classrooms.py
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.dependencies import require_faculty
from app.db.session import get_db
from app.models.classroom import Classroom
from app.schemas.classroom import ClassroomCreate

router = APIRouter(
    prefix="/classrooms",
    tags=["Classrooms"],
    dependencies=[Depends(require_faculty)],
)


@router.post("")
def create_classroom(
    data: ClassroomCreate,
    db: Session = Depends(get_db),
    current_user=Depends(require_faculty),
):
    classroom = Classroom(
        name=data.name,
        faculty_id=current_user.id,
    )

    db.add(classroom)
    db.commit()
    db.refresh(classroom)

    return {
        "id": classroom.id,
        "name": classroom.name,
    }
