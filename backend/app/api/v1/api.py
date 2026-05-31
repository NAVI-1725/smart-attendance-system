# backend\app\api\v1\api.py
from fastapi import APIRouter

from app.api.v1.beacons import router as beacon_router

api_router = APIRouter()

api_router.include_router(beacon_router)
