// mobile_app/lib/features/attendance/presentation/session_state.dart

import '../domain/session.dart';

class SessionState {
  final List<Session> activeSessions;
  final bool isLoading;
  final String? error;
  final Set<String> submittedSessionIds;

  const SessionState({
    this.activeSessions = const [],
    this.isLoading = false,
    this.error,
    this.submittedSessionIds = const {},
  });

  factory SessionState.initial() {
    return const SessionState(
      activeSessions: [],
      isLoading: false,
      submittedSessionIds: const {},
    );
  }

  SessionState copyWith({
    List<Session>? activeSessions,
    bool? isLoading,
    String? error,
    Set<String>? submittedSessionIds,
  }) {
    return SessionState(
      activeSessions: activeSessions ?? this.activeSessions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      submittedSessionIds:
          submittedSessionIds ??
          this.submittedSessionIds,
    );
  }

  bool get hasSessions => activeSessions.isNotEmpty;
}