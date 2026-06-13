// mobile_app/lib/features/attendance/data/attendance_api_service.dart

import 'package:dio/dio.dart';
import '../../../core/services/api_client.dart';
import '../domain/attendance_attempt.dart';
import '../domain/gps_evidence.dart';

class AttendanceAlreadyMarkedException
    implements Exception {
  const AttendanceAlreadyMarkedException();

  @override
  String toString() {
    return 'Attendance already marked';
  }
}

class SessionClosedException
    implements Exception {
  const SessionClosedException();
}

class AttendanceSubmissionException
    implements Exception {
  final String message;

  const AttendanceSubmissionException(
    this.message,
  );

  @override
  String toString() {
    return message;
  }
}

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

      print(
        'ATTENDANCE HTTP STATUS: '
        '$statusCode',
      );

      print(
        'ATTENDANCE ERROR DATA: '
        '$errorData',
      );

      print(
        'ATTENDANCE DIO ERROR: '
        '${e.message}',
      );

      if (statusCode == 403) {
        final code =
            errorData?['detail']?['error']?['code'];

        print('ERROR CODE: $code');

        if (code == 'SESSION_CLOSED') {
          throw const SessionClosedException();
        }
      }

      if (statusCode == 410) {
        throw const SessionClosedException();
      }

      if (statusCode == 409) {
        throw const AttendanceAlreadyMarkedException();
      }

      if (errorData is Map &&
          errorData['detail'] != null) {
        throw AttendanceSubmissionException(
          errorData['detail'].toString(),
        );
      }

      throw const AttendanceSubmissionException(
        'Attendance submission failed',
      );
    }
  }
}