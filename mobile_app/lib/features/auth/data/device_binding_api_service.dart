// mobile_app\lib\features\auth\data\device_binding_api_service.dart
import 'package:dio/dio.dart';
import '../../../core/services/api_client.dart';

class DeviceBindingApiService {
  final ApiClient _apiClient;

  DeviceBindingApiService(this._apiClient);

  Future<void> bindDevice(String deviceId) async {
    try {
      await _apiClient.dio.post(
        '/devices/bind',
        data: {
          'device_id': deviceId,
        },
      );
    } on DioException catch (e) {
      final errorData = e.response?.data;

      if (errorData is Map && errorData['detail'] != null) {
        throw Exception(errorData['detail']);
      }

      throw Exception('Device binding failed');
    }
  }
}
