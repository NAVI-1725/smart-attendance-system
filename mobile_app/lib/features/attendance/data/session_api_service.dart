import 'package:dio/dio.dart';
import '../../../core/services/api_client.dart';
import '../domain/session.dart';

class SessionApiService {
  final ApiClient _apiClient;

  SessionApiService(this._apiClient);

  Future<Session?> getActiveSession() async {
    try {
      final Response response = await _apiClient.dio.get(
        '/sessions/active',
      );

      return Session.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final errorData = e.response?.data;

      if (errorData is Map && errorData['detail'] == 'No active session') {
        return null;
      }

      throw Exception('Failed to fetch active session');
    }
  }
}
