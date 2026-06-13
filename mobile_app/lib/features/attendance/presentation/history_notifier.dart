// mobile_app/lib/features/attendance/presentation/history_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/attendance_history_api_service.dart';
import 'history_state.dart';

class HistoryNotifier
    extends StateNotifier<HistoryState> {
  final AttendanceHistoryApiService _service;

  HistoryNotifier(this._service)
      : super(
          HistoryState.initial(),
        );

  Future<void> loadHistory() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final history =
          await _service.getHistory();

      state = state.copyWith(
        isLoading: false,
        records: history,
      );
    } catch (e) {
      print(
        'HISTORY LOAD ERROR: $e',
      );

      state = state.copyWith(
        isLoading: false,
        error:
            'Unable to load attendance history',
      );
    }
  }
}