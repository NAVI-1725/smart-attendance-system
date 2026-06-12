// mobile_app\lib\core\services\ble\ble_scan_result.dart
class BleScanResult {
  final String beaconId;
  final String classroomId;
  final int rssi;
  final DateTime timestamp;

  final String nonce;
  final String signature;
  final int lastSeenEpochMs;

  BleScanResult({
    required this.beaconId,
    required this.classroomId,
    required this.rssi,
    required this.timestamp,
    required this.nonce,
    required this.signature,
    required this.lastSeenEpochMs,
  });
}