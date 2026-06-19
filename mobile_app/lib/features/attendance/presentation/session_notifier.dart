// mobile_app/lib/features/attendance/presentation/session_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_bootstrap.dart';
import '../data/session_api_service.dart';
import 'session_state.dart';

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier() : super(SessionState.initial());

  Future<void> fetchActiveSessions() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final apiService = SessionApiService(
        AppBootstrap.apiClient,
      );

      final sessions =
          await apiService.getActiveSessions();

      state = state.copyWith(
        activeSessions: sessions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void markSessionSubmitted(
    String sessionId,
  ) {
    final updated =
        Set<String>.from(
      state.submittedSessionIds,
    );

    updated.add(sessionId);

    state = state.copyWith(
      submittedSessionIds: updated,
    );
  }

  void clearSession() {
    state = SessionState.initial();
  }
}