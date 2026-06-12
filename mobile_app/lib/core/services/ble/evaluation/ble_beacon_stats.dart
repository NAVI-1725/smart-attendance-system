// mobile_app\lib\core\services\ble\evaluation\ble_beacon_stats.dart
import 'ble_proximity_level.dart';

class BleBeaconStats {
  final String beaconId;
  final List<int> rssis;

  String? latestNonce;
  String? latestSignature;
  int? lastSeenEpochMs;

  BleBeaconStats._({
    required this.beaconId,
    required this.rssis,
    this.latestNonce,
    this.latestSignature,
    this.lastSeenEpochMs,
  });

  factory BleBeaconStats.empty(String beaconId) {
    return BleBeaconStats._(
      beaconId: beaconId,
      rssis: <int>[],
    );
  }

  void addSample(
    int rssi, {
    String? nonce,
    String? signature,
    int? lastSeenEpochMs,
  }) {
    rssis.add(rssi);

    if (nonce != null) {
      latestNonce = nonce;
    }

    if (signature != null) {
      latestSignature = signature;
    }

    if (lastSeenEpochMs != null) {
      this.lastSeenEpochMs = lastSeenEpochMs;
    }
  }

  int? get averageRssi {
    if (rssis.isEmpty) return null;
    final sum = rssis.reduce((a, b) => a + b);
    return sum ~/ rssis.length;
  }

  int get sampleCount => rssis.length;

  double? get variance {
    if (rssis.length < 2) return null;
    final avg = averageRssi!;
    final squaredDiffs =
        rssis.map((r) => (r - avg) * (r - avg)).reduce((a, b) => a + b);
    return squaredDiffs / rssis.length;
  }

  BleProximityLevel? get proximity {
    if (averageRssi == null) return null;

    final rssi = averageRssi!;
    final levels = BleProximityLevel.values;

    // Assumption (safe & documented):
    // values[0] = closest, values[1] = medium, values[2] = farthest
    if (levels.length < 3) return null;

    if (rssi >= -60) return levels[0];
    if (rssi >= -75) return levels[1];
    return levels[2];
  }
}