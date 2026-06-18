// mobile_app/lib/features/registration/data/registration_api_service.dart

import '../../../core/services/api_client.dart';

class RegistrationApiService {
  final ApiClient _apiClient;

  RegistrationApiService(this._apiClient);

  Future<Map<String, dynamic>> startSession({
    required int courseId,
  }) async {
    final response = await _apiClient.dio.post(
      '/registration-sessions/start',
      data: {
        'course_id': courseId,
      },
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<void> closeSession({
    required int sessionId,
  }) async {
    await _apiClient.dio.post(
      '/registration-sessions/$sessionId/close',
    );
  }

  Future<List<Map<String, dynamic>>> getOpenSessions() async {
    final response = await _apiClient.dio.get(
      '/registration-sessions/open',
    );

    return (response.data as List)
        .map(
          (item) => Map<String, dynamic>.from(
            item as Map,
          ),
        )
        .toList();
  }

  Future<void> joinSession({
    required int sessionId,
  }) async {
    await _apiClient.dio.post(
      '/registration-sessions/$sessionId/join',
    );
  }

  Future<List<Map<String, dynamic>>> getSessionRequests({
    required int sessionId,
  }) async {
    final response = await _apiClient.dio.get(
      '/registration-sessions/$sessionId/requests',
    );

    return (response.data as List)
        .map(
          (item) => Map<String, dynamic>.from(
            item as Map,
          ),
        )
        .toList();
  }

  Future<void> approveRequest({
    required int requestId,
  }) async {
    await _apiClient.dio.post(
      '/registration-sessions/requests/$requestId/approve',
    );
  }

  Future<void> rejectRequest({
    required int requestId,
  }) async {
    await _apiClient.dio.post(
      '/registration-sessions/requests/$requestId/reject',
    );
  }

  Future<void> approveAll({
    required int sessionId,
  }) async {
    await _apiClient.dio.post(
      '/registration-sessions/$sessionId/approve-all',
    );
  }

  Future<void> rejectAll({
    required int sessionId,
  }) async {
    await _apiClient.dio.post(
      '/registration-sessions/$sessionId/reject-all',
    );
  }
}