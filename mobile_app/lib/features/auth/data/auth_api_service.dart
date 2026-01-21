import 'package:dio/dio.dart';
import '../../../core/services/api_client.dart';
import '../domain/login_request.dart';
import '../domain/login_response.dart';

class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService(this._apiClient);

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final Response response = await _apiClient.dio.post(
        '/auth/login',
        data: request.toJson(),
      );

      return LoginResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final detail = e.response?.data['detail'];

      if (statusCode == 403) {
        throw Exception(
          detail ??
              'This account is registered on another device. '
                  'Please contact the academic office.',
        );
      }

      if (statusCode == 401) {
        throw Exception('Invalid email or password');
      }

      throw Exception(detail ?? 'Login failed');
    }
  }
}
