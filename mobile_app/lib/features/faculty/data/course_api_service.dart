// mobile_app/lib/features/faculty/data/course_api_service.dart

import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';
import '../models/course_detail.dart';
import '../models/course_student.dart';
import '../models/faculty_course.dart';
import '../models/student_history.dart';

class CourseApiService {
  final ApiClient _apiClient;

  CourseApiService(this._apiClient);

  Future<List<FacultyCourse>> getCourses() async {
    final Response response =
        await _apiClient.dio.get(
      '/faculty/courses',
    );

    final List<dynamic> data =
        response.data as List<dynamic>;

    return data
        .map(
          (item) => FacultyCourse.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<CourseDetail> getCourseDetail(
    int courseId,
  ) async {
    final Response response =
        await _apiClient.dio.get(
      '/faculty/course/$courseId',
    );

    return CourseDetail.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<List<CourseStudent>> getCourseStudents(
    int courseId,
  ) async {
    final Response response =
        await _apiClient.dio.get(
      '/faculty/course/$courseId/students',
    );

    final List<dynamic> data =
        response.data as List<dynamic>;

    return data
        .map(
          (item) => CourseStudent.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<StudentHistory>> getStudentHistory(
    int studentId,
  ) async {
    final Response response =
        await _apiClient.dio.get(
      '/faculty/student/$studentId/history',
    );

    final List<dynamic> data =
        response.data as List<dynamic>;

    return data
        .map(
          (item) => StudentHistory.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}