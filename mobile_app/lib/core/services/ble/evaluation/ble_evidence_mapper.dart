// mobile_app/lib/core/services/ble/evaluation/ble_evidence_mapper.dart

import 'ble_consistency_result.dart';
import 'ble_proximity_level.dart';

class BleEvidenceMapper {
  static Map<String, dynamic> toJson(BleConsistencyResult result) {
    return {
      // overall is non-null, label is always available
      'overall': result.overall.label,

      'per_beacon': result.perBeacon.map(
        (key, stats) => MapEntry(
          key,
          {
            'beacon_id': stats.beaconId,
            'average_rssi': stats.averageRssi,
            'variance': stats.variance ?? 0.0,
            'sample_count': stats.sampleCount,

            // stats.proximity is nullable → must be handled safely
            // Design freeze allows NONE / UNKNOWN when signal is insufficient
            'proximity':
                (stats.proximity ?? BleProximityLevel.unknown).label,

            'last_seen_epoch_ms': stats.lastSeenEpochMs,
            'nonce': stats.latestNonce,
            'signature': stats.latestSignature,
            'scan_window': 6,
          },
        ),
      ),
    };
  }
}