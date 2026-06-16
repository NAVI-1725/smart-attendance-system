# backend/app/schemas/admin_import.py

from pydantic import BaseModel


class BulkImportResponse(BaseModel):
    created: int
    skipped: int
    errors: list[str]