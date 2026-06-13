// mobile_app/lib/features/profile/data/device_management_api_service.dart

import '../../../core/services/api_client.dart';

class DeviceManagementApiService {
  final ApiClient _apiClient;

  DeviceManagementApiService(
    this._apiClient,
  );

  Future<void> selfUnbind() async {
    final response = await _apiClient.dio.post(
      '/devices/self-unbind',
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to reset device',
      );
    }
  }
}