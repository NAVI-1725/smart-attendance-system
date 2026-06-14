// mobile_app/lib/features/faculty/models/faculty_course.dart

class FacultyCourse {
  final int courseId;
  final String courseCode;
  final String courseName;
  final int studentCount;
  final bool activeSession;

  const FacultyCourse({
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.studentCount,
    required this.activeSession,
  });

  factory FacultyCourse.fromJson(
    Map<String, dynamic> json,
  ) {
    return FacultyCourse(
      courseId: json['course_id'] as int,
      courseCode: json['course_code'] as String,
      courseName: json['course_name'] as String,
      studentCount: json['student_count'] as int,
      activeSession:
          json['active_session'] as bool,
    );
  }
}