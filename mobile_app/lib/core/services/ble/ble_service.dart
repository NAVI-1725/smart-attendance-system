// mobile_app\lib\core\services\ble\ble_service.dart
import 'ble_scan_result.dart';

abstract class BleService {
  /// Start scanning and return BLE samples for a fixed window.
  /// Implementations decide how scanning is done.
  Future<List<BleScanResult>> scan({
    required Duration duration,
  });

  /// Stop scanning immediately (best-effort).
  Future<void> stop();
}
