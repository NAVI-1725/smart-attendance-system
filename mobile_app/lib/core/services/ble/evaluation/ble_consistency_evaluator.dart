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
      ).addSample(sample.rssi);
    }

    return BleConsistencyResult(
      perBeacon: perBeacon,
      overall: BleProximityLevel.unknown,
    );
  }
}
