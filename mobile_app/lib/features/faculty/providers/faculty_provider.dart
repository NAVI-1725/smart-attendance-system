// mobile_app/lib/features/faculty/providers/faculty_provider.dart

import 'package:flutter/foundation.dart';

import '../data/faculty_repository.dart';
import '../models/attendance_detail.dart';
import '../models/attendance_evidence.dart';
import '../models/faculty_course.dart';
import '../models/faculty_dashboard.dart';
import '../models/faculty_session.dart';
import '../models/flagged_attendance.dart';
import '../models/session_attendance.dart';

class FacultyProvider extends ChangeNotifier {
  final FacultyRepository _repository;

  FacultyProvider(this._repository);

  bool isLoading = false;

  FacultyDashboard? dashboard;

  List<FacultySession> sessions = [];

  List<FacultyCourse> courses = [];

  List<FlaggedAttendance> flaggedAttendance = [];

  AttendanceDetail? attendanceDetail;

  AttendanceEvidence? attendanceEvidence;

  SessionAttendance? sessionAttendance;

  Future<void> loadDashboard() async {
    isLoading = true;
    notifyListeners();

    try {
      final data =
          await _repository.getDashboard();

      dashboard = FacultyDashboard.fromJson(
        data,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSessions() async {
    isLoading = true;
    notifyListeners();

    try {
      final data =
          await _repository.getSessions();

      sessions = data
          .map(
            (item) =>
                FacultySession.fromJson(item),
          )
          .toList();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCourses() async {
    isLoading = true;
    notifyListeners();

    try {
      final data =
          await _repository.getCourses();

      courses = data
          .map(
            (item) =>
                FacultyCourse.fromJson(item),
          )
          .toList();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFlaggedAttendance({
    required int classroomId,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await _repository
          .getFlaggedAttendance(
        classroomId: classroomId,
      );

      flaggedAttendance = data
          .map(
            (item) =>
                FlaggedAttendance.fromJson(
              item,
            ),
          )
          .toList();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAttendanceDetail(
    int attendanceId,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await _repository
          .getAttendanceDetail(
        attendanceId,
      );

      attendanceDetail =
          AttendanceDetail.fromJson(data);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAttendanceEvidence(
    int attendanceId,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await _repository
          .getAttendanceEvidence(
        attendanceId,
      );

      attendanceEvidence =
          AttendanceEvidence.fromJson(
        data,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resolveAttendance({
    required int attendanceId,
    required String status,
    required String reason,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repository.resolveAttendance(
        attendanceId: attendanceId,
        status: status,
        reason: reason,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> closeSession(
    int sessionId,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repository.closeSession(
        sessionId,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes [sessionId]. Throws if the backend rejects the deletion
  /// (e.g. 409 because attendance records already exist) — callers
  /// should catch and surface the error message to the user.
  Future<void> deleteSession(
    int sessionId,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repository.deleteSession(
        sessionId,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSessionAttendance(
    int sessionId,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await _repository
          .getSessionAttendance(
        sessionId,
      );

      sessionAttendance =
          SessionAttendance.fromJson(
        data,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}