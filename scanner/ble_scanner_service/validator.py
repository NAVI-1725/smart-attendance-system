# scanner/ble_scanner_service/validator.py

import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[2]

BACKEND_ROOT = PROJECT_ROOT / "backend"

if str(BACKEND_ROOT) not in sys.path:
    sys.path.insert(0, str(BACKEND_ROOT))

from app.db.session import get_db

from app.schemas.attendance import (
    BleEvidence,
)

from app.services.ble_security_service import (
    validate_ble_attendance,
)

from .service import (
    scan_and_build_ble_evidence,
)


async def validate_ble_attendance_status(
    session_id: int,
    classroom_id: int = 1,
):
    ble_evidence_dict = (
        await scan_and_build_ble_evidence()
    )

    ble_evidence = BleEvidence(
        **ble_evidence_dict
    )

    db = next(get_db())

    try:
        return validate_ble_attendance(
            db=db,
            session_id=session_id,
            classroom_id=classroom_id,
            ble=ble_evidence,
        )

    finally:
        db.close()