import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_bootstrap.dart';
import '../data/auth_api_service.dart';
import '../data/auth_repository_impl.dart';
import '../domain/auth_repository.dart';
import 'auth_notifier.dart';
import 'auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = AuthApiService(AppBootstrap.apiClient);
  return AuthRepositoryImpl(apiService);
});

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
