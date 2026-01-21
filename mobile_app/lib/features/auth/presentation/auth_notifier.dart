// mobile_app\lib\features\auth\presentation\auth_notifier.dart
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_bootstrap.dart';
import '../../../core/services/device_id_service.dart';
import '../domain/login_request.dart';
import '../domain/auth_repository.dart';
import '../data/device_binding_api_service.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState.initial());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repository.login(
        LoginRequest(email: email, password: password),
      );

      await AppBootstrap.localStorageService
          .saveAuthToken(response.accessToken);

      final deviceIdService = DeviceIdService(
        AppBootstrap.localStorageService,
      );

      final deviceId = await deviceIdService.getOrCreateDeviceId();

      log(
        'DEVICE ID USED: $deviceId',
        name: 'AuthNotifier',
      );

      final deviceBindingService = DeviceBindingApiService(
        AppBootstrap.apiClient,
      );

      await deviceBindingService.bindDevice(deviceId);

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await AppBootstrap.localStorageService.clearAuthToken();
    state = AuthState.initial();
  }
}
