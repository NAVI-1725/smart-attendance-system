// mobile_app/lib/features/attendance/domain/attendance_history_item.dart

class AttendanceHistoryItem {
  final int attendanceId;

  final String courseCode;
  final String courseName;
  final String status;
  final DateTime timestamp;
  final bool hasClaim;

  const AttendanceHistoryItem({
    required this.attendanceId,

    required this.courseCode,
    required this.courseName,
    required this.status,
    required this.timestamp,
    required this.hasClaim,
  });

  factory AttendanceHistoryItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttendanceHistoryItem(
      attendanceId:
          json['attendance_id'] as int,

      courseCode: json['course_code'] as String,
      courseName: json['course_name'] as String,
      status: json['status'] as String,
      timestamp: DateTime.parse(
        json['timestamp'] as String,
      ),
      hasClaim:
          json['has_claim'] as bool,
    );
  }
}