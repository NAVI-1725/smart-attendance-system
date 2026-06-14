// mobile_app/lib/features/faculty/data/faculty_repository.dart

import 'faculty_api_service.dart';

class FacultyRepository {
  final FacultyApiService _apiService;

  FacultyRepository(this._apiService);

  Future<Map<String, dynamic>> getDashboard() {
    return _apiService.getDashboard();
  }

  Future<List<Map<String, dynamic>>> getFlaggedAttendance({
    required int classroomId,
  }) {
    return _apiService.getFlaggedAttendance(
      classroomId: classroomId,
    );
  }

  Future<Map<String, dynamic>> getAttendanceDetail(
    int attendanceId,
  ) {
    return _apiService.getAttendanceDetail(
      attendanceId,
    );
  }

  Future<Map<String, dynamic>> getAttendanceEvidence(
    int attendanceId,
  ) {
    return _apiService.getAttendanceEvidence(
      attendanceId,
    );
  }

  Future<void> resolveAttendance({
    required int attendanceId,
    required String status,
    required String reason,
  }) {
    return _apiService.resolveAttendance(
      attendanceId: attendanceId,
      status: status,
      reason: reason,
    );
  }

  Future<List<Map<String, dynamic>>> getSessions() {
    return _apiService.getSessions();
  }

  Future<void> startSession({
    required int courseId,
    required int classroomId,
    required int durationMinutes,
  }) {
    return _apiService.startSession(
      courseId: courseId,
      classroomId: classroomId,
      durationMinutes: durationMinutes,
    );
  }

  Future<void> closeSession(
    int sessionId,
  ) {
    return _apiService.closeSession(
      sessionId,
    );
  }

  Future<Map<String, dynamic>> getSessionAttendance(
    int sessionId,
  ) {
    return _apiService.getSessionAttendance(
      sessionId,
    );
  }
}