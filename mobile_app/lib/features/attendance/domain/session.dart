// mobile_app\lib\features\attendance\domain\session.dart
import 'session_status.dart';

class Session {
  final String sessionId;
  final String classId;
  final DateTime startTime;
  final DateTime? endTime;
  final SessionStatus status;

  Session({
    required this.sessionId,
    required this.classId,
    required this.startTime,
    required this.status,
    this.endTime,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionId: json['session_id'] as String,
      classId: json['class_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      status: SessionStatusX.fromString(json['status'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'class_id': classId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'status': status.value,
    };
  }
}
