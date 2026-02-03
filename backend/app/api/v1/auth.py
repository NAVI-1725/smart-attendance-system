# backend\app\api\v1\auth.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.schemas.auth import LoginRequest, TokenResponse
from app.core.security import verify_password
from app.core.jwt import create_access_token
from app.db.session import get_db
from app.models.user import User
from app.models.device import Device
from app.models.session import Session as UserSession
from app.services.device_binding_service import DeviceBindingService

router = APIRouter(tags=["Auth"])


@router.post("/login", response_model=TokenResponse)
def login(data: LoginRequest, db: Session = Depends(get_db)):
    user = (
        db.query(User)
        .filter(User.email == data.email, User.is_active == True)
        .first()
    )

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
        )

    if not verify_password(data.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
        )

    # Device binding
    device_service = DeviceBindingService(db)
    device_service.bind_device(user, data.device_uuid)

    # Ensure device exists (binding guarantees this)
    device = (
        db.query(Device)
        .filter(
            Device.user_id == user.id,
            Device.device_id == data.device_uuid,
            Device.is_active == True,
        )
        .first()
    )

    if not device:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Bound device not found",
        )

    # Kill previous sessions (faculty-based, matches DB)
    db.query(UserSession).filter(
        UserSession.faculty_id == user.id,
        UserSession.is_active == True,
    ).update({"is_active": False})

    # Create new session
    session = UserSession(
        faculty_id=user.id,
        is_active=True,
    )

    db.add(session)
    db.commit()

    access_token = create_access_token(subject=str(user.id), role=user.role)

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "role": user.role,
    }
