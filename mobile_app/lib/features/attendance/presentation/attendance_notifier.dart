// mobile_app/lib/features/attendance/presentation/attendance_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/ble/ble_service.dart';
import '../../../core/services/ble/ble_scan_sample.dart';
import '../../../core/services/ble/evaluation/ble_consistency_evaluator.dart';
import '../../../core/services/ble/evaluation/ble_consistency_result.dart';
import '../../../core/services/ble/evaluation/ble_evidence_mapper.dart';
import '../data/attendance_api_service.dart';
import '../domain/gps_evidence.dart';
import '../services/gps_service.dart';
import 'attendance_state.dart';

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final AttendanceApiService _apiService;
  final BleService _bleService;
  final GpsService _gpsService;

  AttendanceNotifier(
    this._apiService,
    this._bleService,
    this._gpsService,
  ) : super(AttendanceState.initial());

  Future<void> submitAttendance(String sessionId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1️⃣ BLE scan (raw output from service)
      final rawSamples = await _bleService.scan(
        duration: const Duration(seconds: 15),
      );

      print('RAW SAMPLE COUNT: ${rawSamples.length}');

      // 2️⃣ Normalize BLE samples into domain model
      final List<BleScanSample> samples = rawSamples
          .map(
            (sample) => BleScanSample(
              beaconId: sample.beaconId,
              rssi: sample.rssi,
              timestamp: sample.timestamp,
              nonce: sample.nonce,
              signature: sample.signature,
              lastSeenEpochMs: sample.lastSeenEpochMs,
            ),
          )
          .toList();

      print(
        'BLE SAMPLE COUNT: ${samples.length}',
      );

      for (final sample in samples) {
        print(
          'BLE SAMPLE => '
          '${sample.beaconId} '
          '${sample.rssi}',
        );
      }

      // 3️⃣ BLE evaluation
      final BleConsistencyResult bleResult =
          BleConsistencyEvaluator.evaluate(samples);

      // 4️⃣ GPS capture
      final position =
          await _gpsService.getCurrentPosition();

      final gpsEvidence = GPSEvidence(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
        capturedAt:
            position.timestamp?.toUtc() ??
            DateTime.now().toUtc(),
      );

      final bleEvidence =
          BleEvidenceMapper.toJson(
        bleResult,
      );

      print(
        'BLE EVIDENCE JSON: $bleEvidence',
      );

      // 5️⃣ Attendance submission
      final attempt = await _apiService.submitAttendance(
        sessionId: sessionId,

        bleEvidence: bleEvidence,

        gpsEvidence: gpsEvidence,
      );

      state = AttendanceState(
        isLoading: false,
        attempt: attempt,
        bleEvidence: bleResult,
      );
    } catch (e, stackTrace) {
      print('ATTENDANCE ERROR: $e');

      print(stackTrace);

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