// mobile_app/lib/core/services/ble/ble_scan_sample.dart

class BleScanSample {
  final String beaconId;
  final int rssi;
  final DateTime timestamp;

  final String nonce;
  final String signature;
  final int lastSeenEpochMs;

  BleScanSample({
    required this.beaconId,
    required this.rssi,
    required this.timestamp,
    required this.nonce,
    required this.signature,
    required this.lastSeenEpochMs,
  });
}