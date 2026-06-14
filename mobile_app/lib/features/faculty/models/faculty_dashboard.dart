// mobile_app/lib/features/faculty/models/faculty_dashboard.dart

class FacultyDashboard {
  final int activeSessions;
  final int flaggedAttendance;
  final int confirmedToday;
  final int rejectedToday;

  const FacultyDashboard({
    required this.activeSessions,
    required this.flaggedAttendance,
    required this.confirmedToday,
    required this.rejectedToday,
  });

  factory FacultyDashboard.fromJson(
    Map<String, dynamic> json,
  ) {
    return FacultyDashboard(
      activeSessions:
          json['active_sessions'] as int? ?? 0,
      flaggedAttendance:
          json['flagged_attendance'] as int? ?? 0,
      confirmedToday:
          json['confirmed_today'] as int? ?? 0,
      rejectedToday:
          json['rejected_today'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active_sessions': activeSessions,
      'flagged_attendance': flaggedAttendance,
      'confirmed_today': confirmedToday,
      'rejected_today': rejectedToday,
    };
  }
}