import 'attendance_status.dart';

class AttendanceAttempt {
  final String attemptId;
  final String sessionId;
  final String studentId;
  final DateTime timestamp;
  final AttendanceStatus status;
  final bool isFlagged;

  AttendanceAttempt({
    required this.attemptId,
    required this.sessionId,
    required this.studentId,
    required this.timestamp,
    required this.status,
    required this.isFlagged,
  });

  factory AttendanceAttempt.fromJson(Map<String, dynamic> json) {
    return AttendanceAttempt(
      attemptId: json['attempt_id'] as String,
      sessionId: json['session_id'] as String,
      studentId: json['student_id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status:
          AttendanceStatusX.fromString(json['status'] as String),
      isFlagged: json['is_flagged'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attempt_id': attemptId,
      'session_id': sessionId,
      'student_id': studentId,
      'timestamp': timestamp.toIso8601String(),
      'status': status.value,
      'is_flagged': isFlagged,
    };
  }
}
