// mobile_app/lib/features/admin/data/admin_device_api_service.dart

import '../../../core/services/api_client.dart';

class AdminDeviceApiService {
  final ApiClient _apiClient;

  AdminDeviceApiService(
    this._apiClient,
  );

  Future<void> unbindDevice(
    int studentId,
  ) async {
    if (studentId <= 0) {
      throw Exception(
        'Invalid user ID',
      );
    }

    final response = await _apiClient.dio.post(
      '/admin/device/unbind',
      data: {
        'student_id': studentId,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Unable to unbind device',
      );
    }
  }
}