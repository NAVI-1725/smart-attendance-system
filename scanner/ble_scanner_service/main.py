# scanner/ble_scanner_service/main.py

import asyncio
import json

from .scanner import discover_beacons
from .scanner import connect_to_beacon
from .scanner import read_characteristic
from .scanner import collect_all_rssi_statistics

from .parser import parse_characteristic_json
from .parser import build_beacon_evidence
from .parser import build_ble_evidence

from .models import RSSIStatistics

BEACON_CHARACTERISTIC_UUID = (
    "87654321-4321-4321-4321-cba987654321"
)


async def main():
    devices = await discover_beacons()

    if not devices:
        print("Attendance-Beacon not found")
        return

    print("Found Attendance-Beacon")

    rssi_statistics_map = (
        await collect_all_rssi_statistics()
    )

    beacon_evidences = []

    for device in devices:
        rssi_statistics = (
            rssi_statistics_map.get(
                device.address
            )
        )

        if rssi_statistics is None:
            rssi_statistics = RSSIStatistics(
                average_rssi=0.0,
                variance=0.0,
                sample_count=0
            )

        client = await connect_to_beacon(device)

        try:
            print("Connected")

            payload = await read_characteristic(
                client,
                BEACON_CHARACTERISTIC_UUID
            )

            print("Payload Read")

            beacon_payload = parse_characteristic_json(
                payload
            )

            beacon_evidence = build_beacon_evidence(
                beacon_payload,
                rssi_statistics.average_rssi,
                rssi_statistics.variance,
                rssi_statistics.sample_count
            )

            print("BeaconEvidence Built")

            beacon_evidences.append(
                beacon_evidence
            )

        finally:
            await client.disconnect()

    ble_evidence = build_ble_evidence(
        beacon_evidences
    )

    print("BleEvidence Built")

    print(
        json.dumps(
            ble_evidence,
            indent=2
        )
    )


if __name__ == "__main__":
    asyncio.run(main())