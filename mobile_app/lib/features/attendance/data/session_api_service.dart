// mobile_app\lib\features\attendance\data\session_api_service.dart

import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';
import '../domain/session.dart';

class SessionApiService {
  final ApiClient _apiClient;

  SessionApiService(this._apiClient);

  Future<List<Session>>
      getActiveSessions() async {
    try {
      final Response response =
          await _apiClient.dio.get(
        '/sessions/my-active-sessions',
      );

      print(
        'ACTIVE SESSIONS RESPONSE: '
        '${response.data}',
      );

      final List<dynamic> data =
          response.data as List<dynamic>;

      return data
          .map(
            (item) => Session.fromJson(
              item
                  as Map<String, dynamic>,
            ),
          )
          .toList();
    } on DioException {
      throw Exception(
        'Failed to fetch active sessions',
      );
    }
  }
}