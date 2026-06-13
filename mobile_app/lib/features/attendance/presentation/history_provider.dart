// mobile_app/lib/features/attendance/presentation/history_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/api_client_provider.dart';
import '../data/attendance_history_api_service.dart';
import 'history_notifier.dart';
import 'history_state.dart';

final historyNotifierProvider =
    StateNotifierProvider<
        HistoryNotifier,
        HistoryState>(
  (ref) {
    final apiClient =
        ref.read(apiClientProvider);

    return HistoryNotifier(
      AttendanceHistoryApiService(
        apiClient,
      ),
    );
  },
);