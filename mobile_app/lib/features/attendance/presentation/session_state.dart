// mobile_app\lib\features\attendance\presentation\session_state.dart
import '../domain/session.dart';

class SessionState {
  final Session? activeSession;
  final bool isLoading;
  final String? error;

  const SessionState({
    this.activeSession,
    this.isLoading = false,
    this.error,
  });

  factory SessionState.initial() {
    return const SessionState(
      activeSession: null,
      isLoading: false,
    );
  }

  SessionState copyWith({
    Session? activeSession,
    bool? isLoading,
    String? error,
  }) {
    return SessionState(
      activeSession: activeSession,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasActiveSession => activeSession != null;
}
