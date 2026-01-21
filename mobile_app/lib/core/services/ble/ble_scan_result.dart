// mobile_app\lib\core\services\ble\ble_scan_result.dart
class BleScanResult {
  final String beaconId;
  final String classroomId;
  final int rssi;
  final DateTime timestamp;

  BleScanResult({
    required this.beaconId,
    required this.classroomId,
    required this.rssi,
    required this.timestamp,
  });
}
