// mobile_app/lib/features/admin/models/faculty_course_assignment.dart

class FacultyCourseAssignment {
  final int id;

  final int facultyId;
  final String facultyName;

  final int courseId;
  final String courseCode;
  final String courseName;

  const FacultyCourseAssignment({
    required this.id,
    required this.facultyId,
    required this.facultyName,
    required this.courseId,
    required this.courseCode,
    required this.courseName,
  });

  factory FacultyCourseAssignment.fromJson(
    Map<String, dynamic> json,
  ) {
    return FacultyCourseAssignment(
      id: json['id'] as int,
      facultyId:
          json['faculty_id'] as int,
      facultyName:
          json['faculty_name'] as String,
      courseId:
          json['course_id'] as int,
      courseCode:
          json['course_code'] as String,
      courseName:
          json['course_name'] as String,
    );
  }
}