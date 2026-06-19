# backend\app\schemas\beacon_import.py
from pydantic import BaseModel


class BeaconImportError(BaseModel):
    row: int
    reason: str


class BeaconImportResult(BaseModel):
    created: int
    skipped: int
    errors: list[BeaconImportError]