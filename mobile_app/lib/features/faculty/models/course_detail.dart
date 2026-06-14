// mobile_app/lib/features/faculty/models/course_detail.dart

class CourseDetail {
  final int courseId;
  final String courseCode;
  final String courseName;

  final int studentCount;

  final bool activeSession;

  final int? activeSessionId;

  const CourseDetail({
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.studentCount,
    required this.activeSession,
    required this.activeSessionId,
  });

  factory CourseDetail.fromJson(
    Map<String, dynamic> json,
  ) {
    return CourseDetail(
      courseId:
          json['course_id'] as int,
      courseCode:
          json['course_code'] as String,
      courseName:
          json['course_name'] as String,
      studentCount:
          json['student_count'] as int,
      activeSession:
          json['active_session'] as bool,
      activeSessionId:
          json['active_session_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'course_code': courseCode,
      'course_name': courseName,
      'student_count': studentCount,
      'active_session': activeSession,
      'active_session_id': activeSessionId,
    };
  }
}