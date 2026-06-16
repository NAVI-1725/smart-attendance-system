// mobile_app/lib/features/admin/models/enrollment.dart

class Enrollment {
  final int id;

  final int studentId;
  final String studentName;

  final int courseId;
  final String courseCode;
  final String courseName;

  const Enrollment({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.courseId,
    required this.courseCode,
    required this.courseName,
  });

  factory Enrollment.fromJson(
    Map<String, dynamic> json,
  ) {
    return Enrollment(
      id: json['id'] as int,
      studentId:
          json['student_id'] as int,
      studentName:
          json['student_name'] as String,
      courseId:
          json['course_id'] as int,
      courseCode:
          json['course_code'] as String,
      courseName:
          json['course_name'] as String,
    );
  }
}