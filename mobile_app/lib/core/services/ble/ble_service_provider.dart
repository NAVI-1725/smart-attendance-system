// mobile_app\lib\core\services\ble\ble_service_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ble/ble_service.dart';
import '../ble/flutter_ble_service.dart';

final bleServiceProvider = Provider<BleService>((ref) {
  return FlutterBleService();
});