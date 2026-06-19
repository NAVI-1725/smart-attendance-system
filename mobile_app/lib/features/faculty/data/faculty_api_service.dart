// mobile_app/lib/features/faculty/data/faculty_api_service.dart

import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';
import '../models/classroom.dart';

class FacultyApiService {
  final ApiClient _apiClient;

  FacultyApiService(this._apiClient);

  Future<Map<String, dynamic>> getDashboard() async {
    final Response response = await _apiClient.dio.get(
      '/faculty/dashboard',
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<List<Classroom>> getClassrooms() async {
    final Response response = await _apiClient.dio.get(
      '/classrooms',
    );

    final List<dynamic> data =
        response.data as List<dynamic>;

    return data
        .map(
          (item) => Classroom.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> getFlaggedAttendance({
    required int classroomId,
  }) async {
    final Response response = await _apiClient.dio.get(
      '/faculty/flagged-attendance',
      queryParameters: {
        'classroom_id': classroomId,
      },
    );

    return (response.data as List)
        .map(
          (item) => Map<String, dynamic>.from(
            item as Map,
          ),
        )
        .toList();
  }

  Future<Map<String, dynamic>> getAttendanceDetail(
    int attendanceId,
  ) async {
    final Response response = await _apiClient.dio.get(
      '/faculty/attendance/$attendanceId',
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<Map<String, dynamic>> getAttendanceEvidence(
    int attendanceId,
  ) async {
    final Response response = await _apiClient.dio.get(
      '/faculty/attendance/$attendanceId/evidence',
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<void> resolveAttendance({
    required int attendanceId,
    required String status,
    required String reason,
  }) async {
    try {
      await _apiClient.dio.post(
        '/faculty/attendance/resolve',
        data: {
          'attendance_id': attendanceId,
          'new_status': status,
          'reason': reason,
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception(
          'Attendance already reviewed',
        );
      }

      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getSessions() async {
    final Response response = await _apiClient.dio.get(
      '/faculty/sessions',
    );

    return (response.data as List)
        .map(
          (item) => Map<String, dynamic>.from(
            item as Map,
          ),
        )
        .toList();
  }

  Future<void> startSession({
    required int courseId,
    required int classroomId,
    required int durationMinutes,
  }) async {
    await _apiClient.dio.post(
      '/sessions/start',
      data: {
        'course_id': courseId,
        'classroom_id': classroomId,
        'duration_minutes': durationMinutes,
      },
    );
  }

  Future<void> closeSession(
    int sessionId,
  ) async {
    await _apiClient.dio.post(
      '/sessions/$sessionId/close',
    );
  }

  Future<void> deleteSession(
    int sessionId,
  ) async {
    try {
      await _apiClient.dio.delete(
        '/sessions/$sessionId',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception(
          'Cannot delete a session that has attendance records',
        );
      }

      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSessionAttendance(
    int sessionId,
  ) async {
    final Response response = await _apiClient.dio.get(
      '/sessions/$sessionId/attendance',
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<List<Map<String, dynamic>>> getCourses() async {
    final Response response = await _apiClient.dio.get(
      '/faculty/courses',
    );

    return (response.data as List)
        .map(
          (item) => Map<String, dynamic>.from(
            item as Map,
          ),
        )
        .toList();
  }
}