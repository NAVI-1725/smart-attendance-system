# scanner/ble_scanner_service/service.py

from .scanner import discover_beacons
from .scanner import connect_to_beacon
from .scanner import read_characteristic
from .scanner import collect_all_rssi_statistics

from .parser import parse_characteristic_json
from .parser import build_beacon_evidence
from .parser import build_ble_evidence


BEACON_CHARACTERISTIC_UUID = (
    "87654321-4321-4321-4321-cba987654321"
)


async def scan_and_build_ble_evidence():
    devices = await discover_beacons()

    if not devices:
        raise RuntimeError("Attendance-Beacon not found")

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
            rssi_statistics = (
                type(
                    next(
                        iter(
                            rssi_statistics_map.values()
                        ),
                        None
                    )
                )(
                    average_rssi=0.0,
                    variance=0.0,
                    sample_count=0
                )
                if rssi_statistics_map
                else None
            )

        if rssi_statistics is None:
            from .models import (
                RSSIStatistics
            )

            rssi_statistics = (
                RSSIStatistics(
                    average_rssi=0.0,
                    variance=0.0,
                    sample_count=0
                )
            )

        client = await connect_to_beacon(device)

        try:
            payload = await read_characteristic(
                client,
                BEACON_CHARACTERISTIC_UUID
            )

            beacon_payload = parse_characteristic_json(
                payload
            )

            beacon_evidence = build_beacon_evidence(
                beacon_payload,
                rssi_statistics.average_rssi,
                rssi_statistics.variance,
                rssi_statistics.sample_count
            )

            beacon_evidences.append(
                beacon_evidence
            )

        finally:
            await client.disconnect()

    ble_evidence = build_ble_evidence(
        beacon_evidences
    )

    return ble_evidence