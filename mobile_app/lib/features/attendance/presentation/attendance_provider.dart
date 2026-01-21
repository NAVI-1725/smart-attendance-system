// mobile_app\lib\features\attendance\presentation\attendance_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/api_client_provider.dart';
import '../../../core/services/ble/ble_service_provider.dart';
import '../data/attendance_api_service.dart';
import 'attendance_notifier.dart';
import 'attendance_state.dart';

final attendanceNotifierProvider =
    StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final bleService = ref.read(bleServiceProvider);

  final service = AttendanceApiService(apiClient);

  return AttendanceNotifier(
    service,
    bleService,
  );
});
