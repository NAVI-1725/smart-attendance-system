// mobile_app/lib/features/attendance/presentation/history_state.dart

import '../domain/attendance_history_item.dart';

class HistoryState {
  final bool isLoading;
  final String? error;
  final List<AttendanceHistoryItem> records;

  const HistoryState({
    this.isLoading = false,
    this.error,
    this.records = const [],
  });

  factory HistoryState.initial() {
    return const HistoryState();
  }

  HistoryState copyWith({
    bool? isLoading,
    String? error,
    List<AttendanceHistoryItem>? records,
  }) {
    return HistoryState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      records: records ?? this.records,
    );
  }
}