# scanner\ble_scanner_service\validate_main.py
import asyncio

from .validator import (
    validate_ble_attendance_status,
)


ATTENDANCE_SESSION_ID = 10

CLASSROOM_ID = 1


async def main():
    status = (
        await validate_ble_attendance_status(
            session_id=ATTENDANCE_SESSION_ID,
            classroom_id=CLASSROOM_ID,
        )
    )

    print()

    print("Validation Result")

    print(status)


if __name__ == "__main__":
    asyncio.run(main())