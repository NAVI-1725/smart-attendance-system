// mobile_app\lib\features\attendance\data\attendance_api_service.dart
import 'package:dio/dio.dart';
import '../../../core/services/api_client.dart';
import '../domain/attendance_attempt.dart';

class AttendanceApiService {
  final ApiClient _apiClient;

  AttendanceApiService(this._apiClient);

  Future<AttendanceAttempt> submitAttendance({
    required String sessionId,
    Map<String, dynamic>? bleEvidence,
  }) async {
    try {
      final Response response = await _apiClient.dio.post(
        '/attendance/attempt',
        data: {
          'session_id': sessionId,
          if (bleEvidence != null) 'ble_evidence': bleEvidence,
        },
      );

      return AttendanceAttempt.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;

      if (statusCode == 410) {
        throw Exception('Session is closed');
      }

      if (statusCode == 409) {
        throw Exception('Attendance already marked');
      }

      if (errorData is Map && errorData['detail'] != null) {
        throw Exception(errorData['detail']);
      }

      throw Exception('Attendance submission failed');
    }
  }
}
