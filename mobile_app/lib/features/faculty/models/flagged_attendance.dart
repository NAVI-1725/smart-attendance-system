// mobile_app/lib/features/faculty/models/flagged_attendance.dart

class FlaggedAttendance {
  final int attendanceId;
  final String studentName;
  final String courseName;
  final String status;
  final DateTime timestamp;

  const FlaggedAttendance({
    required this.attendanceId,
    required this.studentName,
    required this.courseName,
    required this.status,
    required this.timestamp,
  });

  factory FlaggedAttendance.fromJson(
    Map<String, dynamic> json,
  ) {
    return FlaggedAttendance(
      attendanceId:
          json['attendance_id'] ??
          json['id'] ??
          0,
      studentName:
          json['student_name']
              ?.toString() ??
          '',
      courseName:
          json['course_name']
              ?.toString() ??
          '',
      status:
          json['status']?.toString() ??
          '',
      timestamp: DateTime.parse(
        json['timestamp'].toString(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance_id': attendanceId,
      'student_name': studentName,
      'course_name': courseName,
      'status': status,
      'timestamp':
          timestamp.toIso8601String(),
    };
  }
}