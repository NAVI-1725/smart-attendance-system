import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_bootstrap.dart';
import '../data/session_api_service.dart';
import 'session_state.dart';

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier() : super(SessionState.initial());

  Future<void> fetchActiveSession() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final apiService = SessionApiService(
        AppBootstrap.apiClient,
      );

      final session = await apiService.getActiveSession();

      state = state.copyWith(
        activeSession: session,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearSession() {
    state = SessionState.initial();
  }
}
