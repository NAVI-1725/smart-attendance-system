// mobile_app/lib/core/services/ble/evaluation/ble_consistency_result.dart

import 'package:mobile_app/core/services/ble/evaluation/ble_beacon_stats.dart';
import 'package:mobile_app/core/services/ble/evaluation/ble_proximity_level.dart';

class BleConsistencyResult {
  final Map<String, BleBeaconStats> perBeacon;
  final BleProximityLevel overall;

  BleConsistencyResult({
    required this.perBeacon,
    required this.overall,
  });
}
