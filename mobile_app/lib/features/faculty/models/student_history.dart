// mobile_app/lib/features/faculty/models/student_history.dart

class StudentHistory {
  final int attendanceId;
  final String courseName;
  final String status;
  final DateTime timestamp;

  const StudentHistory({
    required this.attendanceId,
    required this.courseName,
    required this.status,
    required this.timestamp,
  });

  factory StudentHistory.fromJson(
    Map<String, dynamic> json,
  ) {
    return StudentHistory(
      attendanceId:
          json['attendance_id'] as int,
      courseName:
          json['course_name'] as String,
      status:
          json['status'] as String,
      timestamp: DateTime.parse(
        json['timestamp'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance_id': attendanceId,
      'course_name': courseName,
      'status': status,
      'timestamp':
          timestamp.toIso8601String(),
    };
  }
}