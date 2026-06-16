// mobile_app/lib/features/admin/data/admin_device_api_service.dart

import '../../../core/services/api_client.dart';
import '../models/device_search_user.dart';

class AdminDeviceApiService {
  final ApiClient _apiClient;

  AdminDeviceApiService(
    this._apiClient,
  );

  Future<List<DeviceSearchUser>> searchUsers(
    String query,
  ) async {
    final response = await _apiClient.dio.get(
      '/admin/device/search',
      queryParameters: {
        'query': query,
      },
    );

    final List<dynamic> data =
        response.data as List<dynamic>;

    return data
        .map(
          (item) => DeviceSearchUser.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

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