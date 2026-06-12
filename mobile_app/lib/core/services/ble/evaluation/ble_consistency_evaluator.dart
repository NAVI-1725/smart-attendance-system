// mobile_app/lib/core/services/ble/evaluation/ble_consistency_evaluator.dart

import 'package:mobile_app/core/services/ble/evaluation/ble_beacon_stats.dart';
import 'package:mobile_app/core/services/ble/evaluation/ble_proximity_level.dart';
import 'package:mobile_app/core/services/ble/evaluation/ble_consistency_result.dart';
import 'package:mobile_app/core/services/ble/ble_scan_sample.dart';

class BleConsistencyEvaluator {
  static BleConsistencyResult evaluate(
    List<BleScanSample> samples,
  ) {
    final Map<String, BleBeaconStats> perBeacon = {};

    for (final sample in samples) {
      perBeacon.putIfAbsent(
        sample.beaconId,
        () => BleBeaconStats.empty(sample.beaconId),
      ).addSample(
        sample.rssi,
        nonce: sample.nonce,
        signature: sample.signature,
        lastSeenEpochMs: sample.lastSeenEpochMs,
      );
    }

    BleProximityLevel overall =
        BleProximityLevel.unknown;

    if (perBeacon.isNotEmpty) {
      int nearCount = 0;
      int mediumCount = 0;

      for (final stats in perBeacon.values) {
        final proximity = stats.proximity;

        if (proximity == null) {
          continue;
        }

        if (proximity == BleProximityLevel.values[0]) {
          nearCount++;
        } else if (proximity ==
            BleProximityLevel.values[1]) {
          mediumCount++;
        }
      }

      if (nearCount >= 2) {
        overall = BleProximityLevel.values[0];
      } else if (nearCount >= 1 &&
          mediumCount >= 1) {
        overall = BleProximityLevel.values[1];
      } else if (nearCount >= 1) {
        overall = BleProximityLevel.values[0];
      } else if (mediumCount >= 1) {
        overall = BleProximityLevel.values[1];
      } else {
        overall = BleProximityLevel.values.last;
      }
    }

    return BleConsistencyResult(
      perBeacon: perBeacon,
      overall: overall,
    );
  }
}