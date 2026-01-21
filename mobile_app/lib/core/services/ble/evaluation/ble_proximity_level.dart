// mobile_app\lib\core\services\ble\evaluation\ble_proximity_level.dart
enum BleProximityLevel {
  near,
  medium,
  far,
  unknown,
}

extension BleProximityLabel on BleProximityLevel {
  String get label {
    switch (this) {
      case BleProximityLevel.near:
        return 'NEAR';
      case BleProximityLevel.medium:
        return 'MEDIUM';
      case BleProximityLevel.far:
        return 'FAR';
      case BleProximityLevel.unknown:
        return 'UNKNOWN';
    }
  }
}
