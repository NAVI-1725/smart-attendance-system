# backend\app\api\v1\auth.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.schemas.auth import (
    LoginRequest,
    TokenResponse,
    ProfileResponse,
)
from app.core.security import verify_password
from app.core.jwt import create_access_token
from app.db.session import get_db
from app.models.user import User
from app.models.device import Device
from app.models.auth_session import AuthSession
from app.services.device_binding_service import DeviceBindingService
from app.core.auth import get_current_user

router = APIRouter(tags=["Auth"])


@router.post("/login", response_model=TokenResponse)
def login(data: LoginRequest, db: Session = Depends(get_db)):
    user = (
        db.query(User).filter(User.email == data.email, User.is_active).first()
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
            Device.is_active,
        )
        .first()
    )

    if not device:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Bound device not found",
        )

    # Kill previous auth sessions
    db.query(AuthSession).filter(
        AuthSession.user_id == user.id,
        AuthSession.is_active,
    ).update({"is_active": False})

    # Create new session
    session = AuthSession(
        user_id=user.id,
        device_id=device.id,
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


@router.get("/profile", response_model=ProfileResponse)
def get_profile(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    device = (
        db.query(Device)
        .filter(
            Device.user_id == current_user.id,
            Device.is_active,
        )
        .first()
    )

    return {
        "user_id": current_user.id,
        "role": current_user.role,
        "full_name": current_user.full_name,
        "email": current_user.email,
        "device_id": device.device_id if device else None,
    }


@router.post("/logout")
def logout(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    db.query(AuthSession).filter(
        AuthSession.user_id == current_user.id,
        AuthSession.is_active,
    ).update({"is_active": False})

    db.commit()

    return {
        "message": "Logged out successfully",
    }