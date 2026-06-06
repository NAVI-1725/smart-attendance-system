# scanner/ble_scanner_service/scanner.py

import asyncio

from bleak import BleakClient
from bleak import BleakScanner

from .models import RSSIStatistics


async def discover_beacons():
    devices = await BleakScanner.discover()

    return [
        device
        for device in devices
        if device.name
        and device.name.startswith(
            "Attendance-Beacon"
        )
    ]


async def connect_to_beacon(device):
    client = BleakClient(device)

    await client.connect()

    return client


async def read_characteristic(
    client,
    characteristic_uuid: str
):
    value = await client.read_gatt_char(
        characteristic_uuid
    )

    if isinstance(value, (bytes, bytearray)):
        return bytes(value).decode("utf-8")

    return str(value)


async def collect_all_rssi_statistics(
    scan_seconds=5
):
    samples_by_address = {}

    def detection_callback(
        device,
        advertisement_data
    ):
        if (
            device.name
            and device.name.startswith(
                "Attendance-Beacon"
            )
        ):
            if (
                advertisement_data.rssi
                is not None
            ):
                samples_by_address.setdefault(
                    device.address,
                    []
                ).append(
                    advertisement_data.rssi
                )

    scanner = BleakScanner(
        detection_callback=
        detection_callback
    )

    await scanner.start()

    try:
        await asyncio.sleep(
            scan_seconds
        )
    finally:
        await scanner.stop()

    statistics_by_address = {}

    for (
        address,
        rssi_samples
    ) in samples_by_address.items():
        sample_count = len(
            rssi_samples
        )

        if sample_count == 0:
            statistics_by_address[
                address
            ] = RSSIStatistics(
                average_rssi=0.0,
                variance=0.0,
                sample_count=0
            )
            continue

        average_rssi = (
            sum(rssi_samples)
            / sample_count
        )

        variance = (
            sum(
                (
                    sample
                    - average_rssi
                ) ** 2
                for sample
                in rssi_samples
            )
            / sample_count
        )

        statistics_by_address[
            address
        ] = RSSIStatistics(
            average_rssi=average_rssi,
            variance=variance,
            sample_count=sample_count
        )

    return statistics_by_address