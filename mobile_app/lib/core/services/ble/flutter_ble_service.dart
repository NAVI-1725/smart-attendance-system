// mobile_app/lib/core/services/ble/flutter_ble_service.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'ble_beacon_payload.dart';
import 'ble_scan_result.dart';
import 'ble_service.dart';

class FlutterBleService implements BleService {
  static const Set<String> deviceNames = {
    'Attendance-Beacon-1',
    'Attendance-Beacon-2',
  };

  static const String serviceUuid =
      '12345678-1234-1234-1234-123456789abc';

  static const String characteristicUuid =
      '87654321-4321-4321-4321-cba987654321';

  BluetoothDevice? _connectedDevice;

  @override
  Future<BleBeaconPayload> readBeaconPayload() async {
    BluetoothDevice? targetDevice;

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 10),
    );

    await for (final results in FlutterBluePlus.scanResults) {
      for (final result in results) {
        print(
          'DISCOVERED DEVICE: '
          '${result.device.platformName} | '
          '${result.advertisementData.advName}',
        );

        if (deviceNames.contains(
              result.device.platformName,
            ) ||
            deviceNames.contains(
              result.advertisementData.advName,
            )) {
          targetDevice = result.device;
          break;
        }
      }

      if (targetDevice != null) {
        break;
      }
    }

    await FlutterBluePlus.stopScan();

    if (targetDevice == null) {
      throw Exception(
        'Attendance beacon not found',
      );
    }

    _connectedDevice = targetDevice;

    try {
      final payload = await _readPayloadFromDevice(
        targetDevice,
      );

      print(
        'PAYLOAD BEACON ID: ${payload.beaconId}',
      );

      return payload;
    } finally {
      try {
        await targetDevice.disconnect();
      } catch (_) {}
    }
  }

  Future<BleBeaconPayload> _readPayloadFromDevice(
    BluetoothDevice targetDevice,
  ) async {
    try {
      await targetDevice.connect(
        timeout: const Duration(
          seconds: 10,
        ),
      );
    } catch (_) {}

    await Future.delayed(
      const Duration(
        seconds: 1,
      ),
    );

    final services = await targetDevice.discoverServices();

    BluetoothService? targetService;

    for (final service in services) {
      if (service.uuid.toString().toLowerCase() ==
          serviceUuid.toLowerCase()) {
        targetService = service;
        break;
      }
    }

    if (targetService == null) {
      throw Exception(
        'BLE service not found',
      );
    }

    BluetoothCharacteristic? targetCharacteristic;

    for (final characteristic in targetService.characteristics) {
      if (characteristic.uuid.toString().toLowerCase() ==
          characteristicUuid.toLowerCase()) {
        targetCharacteristic = characteristic;
        break;
      }
    }

    if (targetCharacteristic == null) {
      throw Exception(
        'BLE characteristic not found',
      );
    }

    final connected =
        targetDevice.isConnected;

    if (!connected) {
      throw Exception(
        'Device disconnected before read',
      );
    }

    final List<int> rawValue =
        await targetCharacteristic.read();

    final String jsonString =
        utf8.decode(rawValue);

    final Map<String, dynamic> json =
        jsonDecode(jsonString)
            as Map<String, dynamic>;

    return BleBeaconPayload.fromJson(
      json,
    );
  }

  @override
  Future<List<BleScanResult>> scan({
    required Duration duration,
  }) async {
    final Map<String, List<_PendingScanSample>>
        pendingSamplesPerDevice = {};

    final Map<String, BluetoothDevice>
        discoveredDevices = {};

    StreamSubscription<List<ScanResult>>?
        subscription;

    await FlutterBluePlus.startScan(
      timeout: duration,
    );

    subscription =
        FlutterBluePlus.scanResults.listen(
      (scanResults) {
        print(
          'SCAN BATCH SIZE: ${scanResults.length}',
        );

        for (final result in scanResults) {
          print(
            'DEVICE: '
            '${result.device.platformName} | '
            '${result.advertisementData.advName}',
          );

          final bool isTargetBeacon =
              deviceNames.contains(
                    result.device.platformName,
                  ) ||
                  deviceNames.contains(
                    result.advertisementData.advName,
                  );

          if (!isTargetBeacon) {
            continue;
          }

          final deviceKey =
              result.device.remoteId.str;

          discoveredDevices[deviceKey] =
              result.device;

          pendingSamplesPerDevice.putIfAbsent(
            deviceKey,
            () => <_PendingScanSample>[],
          );

          pendingSamplesPerDevice[deviceKey]!.add(
            _PendingScanSample(
              rssi: result.rssi,
              timestamp: DateTime.now(),
            ),
          );
        }
      },
    );

    await Future.delayed(duration);

    await FlutterBluePlus.stopScan();

    print(
      'DISCOVERED DEVICES COUNT: '
      '${discoveredDevices.length}',
    );

    for (final d in discoveredDevices.values) {
      print(
        'DISCOVERED DEVICE FINAL: '
        '${d.platformName}',
      );
    }

    await subscription.cancel();

    if (discoveredDevices.isEmpty) {
      print('SCAN FAIL: targetDevice null');
      return <BleScanResult>[];
    }

    if (pendingSamplesPerDevice.isEmpty) {
      print('SCAN FAIL: pendingSamples empty');
      return <BleScanResult>[];
    }

    print(
      'TARGET DEVICE FOUND',
    );

    final List<BleScanResult> results = [];

    for (final entry
        in discoveredDevices.entries) {
      final device = entry.value;

      final samples =
          pendingSamplesPerDevice[
                  entry.key] ??
              [];

      if (samples.isEmpty) {
        continue;
      }

      _connectedDevice = device;

      try {
        final payload =
            await _readPayloadFromDevice(
          device,
        );

        print(
          'PAYLOAD BEACON ID: '
          '${payload.beaconId}',
        );

        results.addAll(
          samples.map(
            (sample) => BleScanResult(
              beaconId: payload.beaconId,
              classroomId: payload.beaconId,
              rssi: sample.rssi,
              timestamp: sample.timestamp,
              nonce: payload.nonce,
              signature: payload.signature,
              lastSeenEpochMs:
                  payload.timestamp,
            ),
          ),
        );
      } finally {
        try {
          await device.disconnect();
        } catch (_) {}
      }
    }

    return results;
  }

  @override
  Future<void> stop() async {
    await FlutterBluePlus.stopScan();

    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
      } catch (_) {}
    }
  }
}

class _PendingScanSample {
  final int rssi;
  final DateTime timestamp;

  const _PendingScanSample({
    required this.rssi,
    required this.timestamp,
  });
}