// mobile_app/lib/features/faculty/models/session_attendance.dart

class SessionAttendance {
  final int confirmed;
  final int flagged;
  final int rejected;
  final List<SessionAttendanceRecord> records;

  const SessionAttendance({
    required this.confirmed,
    required this.flagged,
    required this.rejected,
    required this.records,
  });

  factory SessionAttendance.fromJson(
    Map<String, dynamic> json,
  ) {
    return SessionAttendance(
      confirmed:
          json['confirmed'] as int? ?? 0,
      flagged:
          json['flagged'] as int? ?? 0,
      rejected:
          json['rejected'] as int? ?? 0,
      records:
          (json['records'] as List<dynamic>? ?? [])
              .map(
                (item) =>
                    SessionAttendanceRecord.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'confirmed': confirmed,
      'flagged': flagged,
      'rejected': rejected,
      'records': records
          .map(
            (record) => record.toJson(),
          )
          .toList(),
    };
  }
}

class SessionAttendanceRecord {
  final int attendanceId;
  final int studentId;
  final String status;

  const SessionAttendanceRecord({
    required this.attendanceId,
    required this.studentId,
    required this.status,
  });

  factory SessionAttendanceRecord.fromJson(
    Map<String, dynamic> json,
  ) {
    return SessionAttendanceRecord(
      attendanceId:
          json['attendance_id'] as int? ?? 0,
      studentId:
          json['student_id'] as int? ?? 0,
      status:
          json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance_id': attendanceId,
      'student_id': studentId,
      'status': status,
    };
  }
}