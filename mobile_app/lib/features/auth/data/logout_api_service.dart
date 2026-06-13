// mobile_app\lib\features\auth\data\logout_api_service.dart
import '../../../core/services/api_client.dart';

class LogoutApiService {
  final ApiClient _apiClient;

  LogoutApiService(
    this._apiClient,
  );

  Future<void> logout() async {
    await _apiClient.dio.post(
      '/auth/logout',
    );
  }
}