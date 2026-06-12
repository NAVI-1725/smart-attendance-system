// mobile_app/lib/features/attendance/domain/session.dart

import 'session_status.dart';

class Session {
  final int sessionId;

  final int courseId;
  final String courseCode;
  final String courseName;

  final int facultyId;
  final String facultyName;

  final int classroomId;
  final String classroomName;

  final DateTime startedAt;
  final DateTime expiresAt;

  final SessionStatus status;

  Session({
    required this.sessionId,
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.facultyId,
    required this.facultyName,
    required this.classroomId,
    required this.classroomName,
    required this.startedAt,
    required this.expiresAt,
    required this.status,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionId: json['session_id'] as int,
      courseId: json['course_id'] as int,
      courseCode: json['course_code'] as String,
      courseName: json['course_name'] as String,
      facultyId: json['faculty_id'] as int,
      facultyName: json['faculty_name'] as String,
      classroomId: json['classroom_id'] as int,
      classroomName: json['classroom_name'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      status: SessionStatusX.fromString(
        json['status'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'course_id': courseId,
      'course_code': courseCode,
      'course_name': courseName,
      'faculty_id': facultyId,
      'faculty_name': facultyName,
      'classroom_id': classroomId,
      'classroom_name': classroomName,
      'started_at': startedAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'status': status.value,
    };
  }
}
