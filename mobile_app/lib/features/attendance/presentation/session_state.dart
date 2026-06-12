// mobile_app/lib/features/attendance/presentation/session_state.dart

import '../domain/session.dart';

class SessionState {
  final List<Session> activeSessions;
  final bool isLoading;
  final String? error;

  const SessionState({
    this.activeSessions = const [],
    this.isLoading = false,
    this.error,
  });

  factory SessionState.initial() {
    return const SessionState(
      activeSessions: [],
      isLoading: false,
    );
  }

  SessionState copyWith({
    List<Session>? activeSessions,
    bool? isLoading,
    String? error,
  }) {
    return SessionState(
      activeSessions: activeSessions ?? this.activeSessions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasSessions => activeSessions.isNotEmpty;
}