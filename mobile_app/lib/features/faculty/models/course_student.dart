// mobile_app/lib/features/faculty/models/course_student.dart

class CourseStudent {
  final int studentId;
  final String studentName;
  final double attendancePercentage;

  const CourseStudent({
    required this.studentId,
    required this.studentName,
    required this.attendancePercentage,
  });

  factory CourseStudent.fromJson(
    Map<String, dynamic> json,
  ) {
    return CourseStudent(
      studentId: json['student_id'] as int,
      studentName: json['student_name'] as String,
      attendancePercentage:
          (json['attendance_percentage'] as num)
              .toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'student_name': studentName,
      'attendance_percentage':
          attendancePercentage,
    };
  }
}