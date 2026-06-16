// mobile_app/lib/features/admin/models/admin_course.dart

class AdminCourse {
  final int id;
  final String courseCode;
  final String courseName;

  const AdminCourse({
    required this.id,
    required this.courseCode,
    required this.courseName,
  });

  factory AdminCourse.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminCourse(
      id: json['id'] as int,
      courseCode:
          json['course_code'] as String,
      courseName:
          json['course_name'] as String,
    );
  }
}