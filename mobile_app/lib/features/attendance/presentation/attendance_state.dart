// mobile_app\lib\features\attendance\presentation\attendance_state.dart
import '../domain/attendance_attempt.dart';
import '../../../core/services/ble/evaluation/ble_consistency_result.dart';

class AttendanceState {
  final bool isLoading;
  final AttendanceAttempt? attempt;
  final BleConsistencyResult? bleEvidence;
  final String? error;

  const AttendanceState({
    this.isLoading = false,
    this.attempt,
    this.bleEvidence,
    this.error,
  });

  AttendanceState copyWith({
    bool? isLoading,
    AttendanceAttempt? attempt,
    BleConsistencyResult? bleEvidence,
    String? error,
  }) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
      attempt: attempt ?? this.attempt,
      bleEvidence: bleEvidence ?? this.bleEvidence,
      error: error,
    );
  }

  factory AttendanceState.initial() {
    return const AttendanceState();
  }
}
