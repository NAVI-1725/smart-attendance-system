// mobile_app\lib\core\services\ble\bluetooth_disabled_exception.dart
// mobile_app/lib/core/services/ble/bluetooth_disabled_exception.dart

/// Thrown when a BLE operation is requested while the
/// device Bluetooth adapter is not enabled.
///
/// This exception is intended to be caught by higher layers
/// (e.g. attendance_notifier.dart) and mapped to a
/// user-friendly message such as:
///
/// "Bluetooth is turned off"
class BluetoothDisabledException
    implements Exception {
  const BluetoothDisabledException();

  @override
  String toString() {
    return 'Bluetooth is turned off';
  }
}