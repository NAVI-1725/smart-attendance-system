// mobile_app/lib/core/services/ble/ble_scan_sample.dart

class BleScanSample {
  final String beaconId;
  final int rssi;
  final DateTime timestamp;

  BleScanSample({
    required this.beaconId,
    required this.rssi,
    required this.timestamp,
  });
}
