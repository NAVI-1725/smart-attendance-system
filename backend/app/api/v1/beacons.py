# backend\app\api\v1\beacons.py

from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    status,
)
from sqlalchemy.orm import Session

from app.db.session import get_db

from app.schemas.trusted_beacon import (
    TrustedBeaconCreate,
    TrustedBeaconUpdate,
    TrustedBeaconResponse,
)

from app.models.trusted_ble_beacon import (
    TrustedBLEBeacon,
)

router = APIRouter(
    prefix="/beacons",
    tags=["Beacons"],
)


@router.post(
    "/register",
    response_model=TrustedBeaconResponse,
)
def register_beacon(
    data: TrustedBeaconCreate,
    db: Session = Depends(get_db),
):
    existing = (
        db.query(TrustedBLEBeacon)
        .filter(
            TrustedBLEBeacon.beacon_uuid == data.beacon_uuid,
        )
        .first()
    )

    if existing:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Beacon UUID already exists",
        )

    beacon = TrustedBLEBeacon(
        classroom_id=data.classroom_id,
        beacon_uuid=data.beacon_uuid,
        beacon_name=data.beacon_name,
    )

    db.add(beacon)
    db.commit()
    db.refresh(beacon)

    return beacon


@router.get(
    "",
    response_model=list[TrustedBeaconResponse],
)
def get_beacons(
    db: Session = Depends(get_db),
):
    return (
        db.query(TrustedBLEBeacon)
        .order_by(TrustedBLEBeacon.id.asc())
        .all()
    )


@router.get(
    "/{beacon_id}",
    response_model=TrustedBeaconResponse,
)
def get_beacon(
    beacon_id: int,
    db: Session = Depends(get_db),
):
    beacon = (
        db.query(TrustedBLEBeacon)
        .filter(
            TrustedBLEBeacon.id == beacon_id,
        )
        .first()
    )

    if not beacon:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Beacon not found",
        )

    return beacon


@router.put(
    "/{beacon_id}",
    response_model=TrustedBeaconResponse,
)
def update_beacon(
    beacon_id: int,
    data: TrustedBeaconUpdate,
    db: Session = Depends(get_db),
):
    beacon = (
        db.query(TrustedBLEBeacon)
        .filter(
            TrustedBLEBeacon.id == beacon_id,
        )
        .first()
    )

    if not beacon:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Beacon not found",
        )

    duplicate = (
        db.query(TrustedBLEBeacon)
        .filter(
            TrustedBLEBeacon.beacon_uuid == data.beacon_uuid,
            TrustedBLEBeacon.id != beacon_id,
        )
        .first()
    )

    if duplicate:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Beacon UUID already exists",
        )

    beacon.classroom_id = data.classroom_id
    beacon.beacon_uuid = data.beacon_uuid
    beacon.beacon_name = data.beacon_name
    beacon.is_active = data.is_active

    db.commit()
    db.refresh(beacon)

    return beacon


@router.delete(
    "/{beacon_id}",
    status_code=status.HTTP_200_OK,
)
def delete_beacon(
    beacon_id: int,
    db: Session = Depends(get_db),
):
    beacon = (
        db.query(TrustedBLEBeacon)
        .filter(
            TrustedBLEBeacon.id == beacon_id,
        )
        .first()
    )

    if not beacon:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Beacon not found",
        )

    db.delete(beacon)
    db.commit()

    return {
        "message": "Beacon deleted successfully",
    }