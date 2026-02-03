# backend\app\schemas\classroom.py
from pydantic import BaseModel


class ClassroomCreate(BaseModel):
    name: str
