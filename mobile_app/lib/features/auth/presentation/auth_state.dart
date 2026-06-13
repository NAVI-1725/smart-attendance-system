// mobile_app\lib\features\auth\presentation\auth_state.dart
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final String? role;

  const AuthState({
    required this.isAuthenticated,
    this.isLoading = false,
    this.error,
    this.role,
  });

  factory AuthState.initial() {
    return const AuthState(
      isAuthenticated: false,
      isLoading: false,
      role: null,
    );
  }

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    String? role,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      role: role ?? this.role,
    );
  }
}