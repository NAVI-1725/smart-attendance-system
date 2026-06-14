// mobile_app/lib/features/faculty/providers/course_provider.dart

import 'package:flutter/foundation.dart';

import '../data/course_api_service.dart';
import '../models/course_detail.dart';
import '../models/course_student.dart';
import '../models/faculty_course.dart';
import '../models/student_history.dart';

class CourseProvider extends ChangeNotifier {
  final CourseApiService _apiService;

  CourseProvider(this._apiService);

  bool isLoading = false;

  List<FacultyCourse> courses = [];

  CourseDetail? courseDetail;

  List<CourseStudent> courseStudents = [];

  List<StudentHistory> studentHistory = [];

  Future<void> loadCourses() async {
    isLoading = true;
    notifyListeners();

    try {
      courses = await _apiService.getCourses();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCourseDetail(
    int courseId,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      courseDetail =
          await _apiService.getCourseDetail(
        courseId,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCourseStudents(
    int courseId,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      courseStudents =
          await _apiService.getCourseStudents(
        courseId,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStudentHistory(
    int studentId,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      studentHistory =
          await _apiService.getStudentHistory(
        studentId,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearCourseDetail() {
    courseDetail = null;
    courseStudents = [];
    notifyListeners();
  }

  void clearStudentHistory() {
    studentHistory = [];
    notifyListeners();
  }

  void clearAll() {
    courses = [];
    courseDetail = null;
    courseStudents = [];
    studentHistory = [];
    notifyListeners();
  }
}