// mobile_app/lib/features/faculty/models/faculty_session.dart

class FacultySession {
  final int sessionId;
  final String courseName;
  final String status;
  final DateTime startedAt;
  final DateTime? closedAt;

  const FacultySession({
    required this.sessionId,
    required this.courseName,
    required this.status,
    required this.startedAt,
    required this.closedAt,
  });

  factory FacultySession.fromJson(
    Map<String, dynamic> json,
  ) {
    return FacultySession(
      sessionId:
          json['session_id'] as int? ?? 0,
      courseName:
          json['course_name']?.toString() ?? '',
      status:
          json['status']?.toString() ?? '',
      startedAt: DateTime.parse(
        json['started_at'].toString(),
      ),
      closedAt: json['closed_at'] != null
          ? DateTime.parse(
              json['closed_at'].toString(),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'course_name': courseName,
      'status': status,
      'started_at': startedAt.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
    };
  }
}