# backend/app/core/dependencies.py

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwt, JWTError
from sqlalchemy.orm import Session

from app.core.config import settings
from app.db.session import get_db
from app.models.permissions import Permission
from app.models.user import User
from app.core.constants.roles import UserRole

security = HTTPBearer()

ROLE_PERMISSIONS = {
    UserRole.ADMIN.value: {
        Permission.manage_system,
        Permission.manage_faculty,
        Permission.take_attendance,
    },
    UserRole.FACULTY.value: {
        Permission.take_attendance,
    },
    UserRole.STUDENT.value: set(),
}


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db),
) -> User:
    token = credentials.credentials

    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM],
        )
        user_id: str = payload.get("sub")
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token",
        )

    user = db.query(User).filter(User.id == int(user_id)).first()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
        )

    # Normalize role coming from DB (DB stores uppercase like "FACULTY")
    # Safest option: coerce into canonical lowercase string if needed
    if isinstance(user.role, str):
        try:
            user.role = user.role.lower()
        except Exception:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Invalid user role",
            )

    return user


def require_faculty(current_user=Depends(get_current_user)):
    if current_user.role != UserRole.FACULTY.value:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Faculty access required",
        )
    return current_user


def require_admin(current_user=Depends(get_current_user)):
    if current_user.role != UserRole.ADMIN.value:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required",
        )
    return current_user


def require_admin_or_faculty(
    current_user=Depends(get_current_user),
):
    if current_user.role not in [
        UserRole.ADMIN.value,
        UserRole.FACULTY.value,
    ]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Faculty or Admin access required",
        )

    return current_user


def require_permission(permission: Permission):
    def checker(current_user=Depends(get_current_user)):
        allowed = ROLE_PERMISSIONS.get(current_user.role, set())
        if permission not in allowed:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Permission denied",
            )
        return current_user

    return checker