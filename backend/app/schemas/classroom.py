# backend/app/schemas/classroom.py

from pydantic import BaseModel


class ClassroomCreate(BaseModel):
    name: str
    latitude: float
    longitude: float
    gps_radius_meters: int


class ClassroomUpdate(BaseModel):
    name: str
    latitude: float
    longitude: float
    gps_radius_meters: int


class ClassroomResponse(BaseModel):
    id: int
    name: str
    latitude: float
    longitude: float
    gps_radius_meters: int

    class Config:
        from_attributes = True