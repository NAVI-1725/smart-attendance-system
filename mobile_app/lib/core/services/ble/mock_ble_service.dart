// mobile_app\lib\core\services\ble\mock_ble_service.dart
import 'dart:async';
import 'dart:math';

import 'ble_service.dart';
import 'ble_scan_result.dart';

class MockBleService implements BleService {
  final Random _random = Random();

  final String classroomId;
  final List<String> beaconIds;

  MockBleService({
    required this.classroomId,
    required this.beaconIds,
  });

  bool _scanning = false;

  @override
  Future<List<BleScanResult>> scan({
    required Duration duration,
  }) async {
    _scanning = true;
    final List<BleScanResult> results = [];

    final endTime = DateTime.now().add(duration);

    while (_scanning && DateTime.now().isBefore(endTime)) {
      for (final beaconId in beaconIds) {
        results.add(
          BleScanResult(
            beaconId: beaconId,
            classroomId: classroomId,
            rssi: _simulateRssi(beaconId),
            timestamp: DateTime.now(),
          ),
        );
      }

      await Future.delayed(const Duration(milliseconds: 400));
    }

    return results;
  }

  @override
  Future<void> stop() async {
    _scanning = false;
  }

  int _simulateRssi(String beaconId) {
    // Simulate two-beacon consistency
    // Beacon A slightly stronger than Beacon B (diagonal effect)
    final base = beaconId.endsWith('A') ? -60 : -65;

    // Add environmental noise
    return base + _random.nextInt(8) - 4;
  }
}
