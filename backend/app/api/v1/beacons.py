# backend\app\api\v1\beacons.py
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.session import get_db

from app.schemas.trusted_beacon import (
    TrustedBeaconCreate,
)

from app.models.trusted_ble_beacon import (
    TrustedBLEBeacon,
)

router = APIRouter(
    prefix="/beacons",
    tags=["Beacons"],
)


@router.post("/register")
def register_beacon(
    data: TrustedBeaconCreate,
    db: Session = Depends(get_db),
):

    beacon = TrustedBLEBeacon(
        classroom_id=data.classroom_id,
        beacon_uuid=data.beacon_uuid,
        beacon_name=data.beacon_name,
    )

    db.add(beacon)
    db.commit()
    db.refresh(beacon)

    return beacon
