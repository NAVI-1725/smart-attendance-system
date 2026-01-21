# backend\app\api\v1\sessions.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session as DBSession

from app.db.session import get_db
from app.core.auth import get_current_user
from app.models.session import Session
from app.models.user import User

router = APIRouter(prefix="/sessions", tags=["Sessions"])


@router.post("/start")
def start_session(
    db: DBSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role != "FACULTY":
        raise HTTPException(status_code=403, detail="Only faculty can start sessions")

    session = Session(faculty_id=current_user.id, is_active=True)
    db.add(session)
    db.commit()
    db.refresh(session)

    return {"session_id": session.id}


@router.get("/active")
def get_active_session(db: DBSession = Depends(get_db)):
    session = db.query(Session).filter(Session.is_active == True).first()
    return {"session_id": session.id} if session else None
