import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ble/ble_service.dart';
import '../ble/mock_ble_service.dart';

final bleServiceProvider = Provider<BleService>((ref) {
  return MockBleService(
    classroomId: 'ROOM-101',
    beaconIds: ['BEACON-A', 'BEACON-B'],
  );
});
