// mobile_app/lib/features/registration/models/registration_session.dart

class RegistrationSession {
  final int id;

  final int courseId;
  final String courseCode;
  final String courseName;

  final int facultyId;

  final bool isActive;

  const RegistrationSession({
    required this.id,
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.facultyId,
    required this.isActive,
  });

  factory RegistrationSession.fromJson(
    Map<String, dynamic> json,
  ) {
    return RegistrationSession(
      id: json['id'] as int,
      courseId: json['course_id'] as int,
      courseCode: json['course_code'] as String,
      courseName: json['course_name'] as String,
      facultyId: json['faculty_id'] as int,
      isActive: json['is_active'] as bool,
    );
  }
}