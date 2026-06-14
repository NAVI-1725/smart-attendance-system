// mobile_app/lib/features/faculty/models/attendance_detail.dart

class AttendanceDetail {
  final int attendanceId;
  final int studentId;
  final int sessionId;
  final String status;

  final String studentName;
  final String courseName;

  final String? reviewedBy;
  final DateTime? reviewedAt;

  final String? resolutionReason;

  const AttendanceDetail({
    required this.attendanceId,
    required this.studentId,
    required this.sessionId,
    required this.status,
    required this.studentName,
    required this.courseName,
    required this.reviewedBy,
    required this.reviewedAt,
    required this.resolutionReason,
  });

  factory AttendanceDetail.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttendanceDetail(
      attendanceId:
          json['attendance_id'] as int? ?? 0,
      studentId:
          json['student_id'] as int? ?? 0,
      sessionId:
          json['session_id'] as int? ?? 0,
      status:
          json['status']?.toString() ?? '',
      studentName:
          json['student_name']
                  ?.toString() ??
              '',
      courseName:
          json['course_name']
                  ?.toString() ??
              '',
      reviewedBy:
          json['reviewed_by']
              ?.toString(),
      reviewedAt:
          json['reviewed_at'] != null
              ? DateTime.parse(
                  json['reviewed_at']
                      .toString(),
                )
              : null,
      resolutionReason:
          json['resolution_reason']
              ?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance_id': attendanceId,
      'student_id': studentId,
      'session_id': sessionId,
      'status': status,
      'student_name': studentName,
      'course_name': courseName,
      'reviewed_by': reviewedBy,
      'reviewed_at':
          reviewedAt?.toIso8601String(),
      'resolution_reason':
          resolutionReason,
    };
  }
}