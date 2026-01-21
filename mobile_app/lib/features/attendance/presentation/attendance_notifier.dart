// mobile_app/lib/features/attendance/presentation/attendance_notifier.dart

// mobile_app/lib/features/attendance/presentation/attendance_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/ble/ble_service.dart';
import '../../../core/services/ble/ble_scan_sample.dart';
import '../../../core/services/ble/evaluation/ble_consistency_evaluator.dart';
import '../../../core/services/ble/evaluation/ble_consistency_result.dart';
import '../data/attendance_api_service.dart';
import 'attendance_state.dart';

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final AttendanceApiService _apiService;
  final BleService _bleService;

  AttendanceNotifier(
    this._apiService,
    this._bleService,
  ) : super(AttendanceState.initial());

  Future<void> submitAttendance(String sessionId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1️⃣ BLE scan (raw output from service)
      final rawSamples = await _bleService.scan(
        duration: const Duration(seconds: 6),
      );

      // 2️⃣ Normalize BLE samples into domain model
      // Safest assumption: BLEService returns iterable scan data
      final List<BleScanSample> samples = rawSamples
          .whereType<BleScanSample>()
          .toList();

      // 3️⃣ BLE evaluation
      final BleConsistencyResult bleResult =
          BleConsistencyEvaluator.evaluate(samples);

      // 4️⃣ Attendance submission (BLE evidence used later)
      final attempt = await _apiService.submitAttendance(
        sessionId: sessionId,
      );

      state = AttendanceState(
        isLoading: false,
        attempt: attempt,
        bleEvidence: bleResult,
      );
    } catch (e) {
      state = AttendanceState(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void reset() {
    state = AttendanceState.initial();
  }
}
