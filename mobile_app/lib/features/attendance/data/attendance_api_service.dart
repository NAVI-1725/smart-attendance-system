// mobile_app/lib/features/attendance/data/session_api_service.dart

import 'package:dio/dio.dart';
import '../../../core/services/api_client.dart';
import '../domain/attendance_attempt.dart';
import '../domain/gps_evidence.dart';

class AttendanceApiService {
  final ApiClient _apiClient;

  AttendanceApiService(this._apiClient);

  Future<AttendanceAttempt> submitAttendance({
    required String sessionId,
    required Map<String, dynamic> bleEvidence,
    required GPSEvidence gpsEvidence,
  }) async {
    try {
      final Response response = await _apiClient.dio.post(
        '/attendance/attempt',
        data: {
          'session_id': sessionId,
          'ble_evidence': bleEvidence,
          'gps_evidence': gpsEvidence.toJson(),
        },
      );

      print(
        'ATTENDANCE RESPONSE: '
        '${response.data}',
      );

      print(
        'RAW RESPONSE DATA: ${response.data}',
      );

      return AttendanceAttempt.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final statusCode =
          e.response?.statusCode;

      final errorData =
          e.response?.data;

      if (statusCode == 410) {
        throw Exception(
          'Session is closed',
        );
      }

      if (statusCode == 409) {
        throw Exception(
          'Attendance already marked',
        );
      }

      if (errorData is Map &&
          errorData['detail'] != null) {
        throw Exception(
          errorData['detail'],
        );
      }

      throw Exception(
        'Attendance submission failed',
      );
    }
  }
}