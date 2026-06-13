// mobile_app/lib/features/attendance/domain/attendance_history_item.dart

class AttendanceHistoryItem {
  final String courseCode;
  final String courseName;
  final String status;
  final DateTime timestamp;

  const AttendanceHistoryItem({
    required this.courseCode,
    required this.courseName,
    required this.status,
    required this.timestamp,
  });

  factory AttendanceHistoryItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttendanceHistoryItem(
      courseCode: json['course_code'] as String,
      courseName: json['course_name'] as String,
      status: json['status'] as String,
      timestamp: DateTime.parse(
        json['timestamp'] as String,
      ),
    );
  }
}