// mobile_app/lib/features/admin/data/admin_api_service.dart

import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class AdminApiService {
  final ApiClient _apiClient;

  AdminApiService(this._apiClient);

  Future<Map<String, dynamic>>
      getSystemSummary() async {
    final Response response =
        await _apiClient.dio.get(
      '/admin/system-summary',
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<List<dynamic>> getStudents() async {
    final Response response =
        await _apiClient.dio.get(
      '/admin/students',
    );

    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>>
      createStudent({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final Response response =
        await _apiClient.dio.post(
      '/admin/students',
      data: {
        'full_name': fullName,
        'email': email,
        'password': password,
      },
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<Map<String, dynamic>>
      getStudent(
    int studentId,
  ) async {
    final Response response =
        await _apiClient.dio.get(
      '/admin/students/$studentId',
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<Map<String, dynamic>>
      updateStudent({
    required int studentId,
    required String fullName,
    required String email,
    required bool isActive,
  }) async {
    final Response response =
        await _apiClient.dio.put(
      '/admin/students/$studentId',
      data: {
        'full_name': fullName,
        'email': email,
        'is_active': isActive,
      },
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<void> deleteStudent(
    int studentId,
  ) async {
    await _apiClient.dio.delete(
      '/admin/students/$studentId',
    );
  }

  Future<Map<String, dynamic>>
      importStudents(
    String filePath,
  ) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: filePath
            .split('/')
            .last,
      ),
    });

    final Response response =
        await _apiClient.dio.post(
      '/admin/students/import',
      data: formData,
      options: Options(
        contentType:
            'multipart/form-data',
      ),
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<List<dynamic>> getFaculty() async {
    final Response response =
        await _apiClient.dio.get(
      '/admin/faculty',
    );

    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>>
      createFaculty({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final Response response =
        await _apiClient.dio.post(
      '/admin/faculty',
      data: {
        'full_name': fullName,
        'email': email,
        'password': password,
      },
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<Map<String, dynamic>>
      getFacultyMember(
    int facultyId,
  ) async {
    final Response response =
        await _apiClient.dio.get(
      '/admin/faculty/$facultyId',
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<Map<String, dynamic>>
      updateFaculty({
    required int facultyId,
    required String fullName,
    required String email,
    required bool isActive,
  }) async {
    final Response response =
        await _apiClient.dio.put(
      '/admin/faculty/$facultyId',
      data: {
        'full_name': fullName,
        'email': email,
        'is_active': isActive,
      },
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<void> deleteFaculty(
    int facultyId,
  ) async {
    await _apiClient.dio.delete(
      '/admin/faculty/$facultyId',
    );
  }

  Future<Map<String, dynamic>>
      importFaculty(
    String filePath,
  ) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: filePath
            .split('/')
            .last,
      ),
    });

    final Response response =
        await _apiClient.dio.post(
      '/admin/faculty/import',
      data: formData,
      options: Options(
        contentType:
            'multipart/form-data',
      ),
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<List<dynamic>> getCourses() async {
    final Response response =
        await _apiClient.dio.get(
      '/admin/courses',
    );

    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>>
      createCourse({
    required String courseCode,
    required String courseName,
  }) async {
    final Response response =
        await _apiClient.dio.post(
      '/admin/courses',
      data: {
        'course_code': courseCode,
        'course_name': courseName,
      },
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<Map<String, dynamic>>
      getCourse(
    int courseId,
  ) async {
    final Response response =
        await _apiClient.dio.get(
      '/admin/courses/$courseId',
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<Map<String, dynamic>>
      updateCourse({
    required int courseId,
    required String courseCode,
    required String courseName,
  }) async {
    final Response response =
        await _apiClient.dio.put(
      '/admin/courses/$courseId',
      data: {
        'course_code': courseCode,
        'course_name': courseName,
      },
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<void> deleteCourse(
    int courseId,
  ) async {
    await _apiClient.dio.delete(
      '/admin/courses/$courseId',
    );
  }

  Future<List<dynamic>>
      getFacultyCourseAssignments() async {
    final Response response =
        await _apiClient.dio.get(
      '/admin/faculty-course',
    );

    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>>
      createFacultyCourseAssignment({
    required int facultyId,
    required int courseId,
  }) async {
    final Response response =
        await _apiClient.dio.post(
      '/admin/faculty-course',
      data: {
        'faculty_id': facultyId,
        'course_id': courseId,
      },
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<void>
      deleteFacultyCourseAssignment(
    int assignmentId,
  ) async {
    await _apiClient.dio.delete(
      '/admin/faculty-course/$assignmentId',
    );
  }

  Future<List<dynamic>>
      getEnrollments() async {
    final Response response =
        await _apiClient.dio.get(
      '/admin/enrollments',
    );

    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>>
      createEnrollment({
    required int studentId,
    required int courseId,
  }) async {
    final Response response =
        await _apiClient.dio.post(
      '/admin/enrollments',
      data: {
        'student_id': studentId,
        'course_id': courseId,
      },
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<void> deleteEnrollment(
    int enrollmentId,
  ) async {
    await _apiClient.dio.delete(
      '/admin/enrollments/$enrollmentId',
    );
  }

  Future<List<dynamic>>
      getClassrooms() async {
    final Response response =
        await _apiClient.dio.get(
      '/classrooms',
    );

    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>>
      createClassroom({
    required String name,
    required double latitude,
    required double longitude,
    required int gpsRadiusMeters,
  }) async {
    final Response response =
        await _apiClient.dio.post(
      '/classrooms',
      data: {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'gps_radius_meters':
            gpsRadiusMeters,
      },
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<Map<String, dynamic>>
      getClassroom(
    int classroomId,
  ) async {
    final Response response =
        await _apiClient.dio.get(
      '/classrooms/$classroomId',
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<Map<String, dynamic>>
      updateClassroom({
    required int classroomId,
    required String name,
    required double latitude,
    required double longitude,
    required int gpsRadiusMeters,
  }) async {
    final Response response =
        await _apiClient.dio.put(
      '/classrooms/$classroomId',
      data: {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'gps_radius_meters':
            gpsRadiusMeters,
      },
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<void> deleteClassroom(
    int classroomId,
  ) async {
    await _apiClient.dio.delete(
      '/classrooms/$classroomId',
    );
  }

  Future<List<dynamic>> getBeacons() async {
    final Response response =
        await _apiClient.dio.get(
      '/beacons',
    );

    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>>
      createBeacon({
    required int classroomId,
    required String beaconUuid,
    String? beaconName,
  }) async {
    final Response response =
        await _apiClient.dio.post(
      '/beacons/register',
      data: {
        'classroom_id': classroomId,
        'beacon_uuid': beaconUuid,
        'beacon_name': beaconName,
      },
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<Map<String, dynamic>>
      getBeacon(
    int beaconId,
  ) async {
    final Response response =
        await _apiClient.dio.get(
      '/beacons/$beaconId',
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<Map<String, dynamic>>
      updateBeacon({
    required int beaconId,
    required int classroomId,
    required String beaconUuid,
    String? beaconName,
    required bool isActive,
  }) async {
    final Response response =
        await _apiClient.dio.put(
      '/beacons/$beaconId',
      data: {
        'classroom_id': classroomId,
        'beacon_uuid': beaconUuid,
        'beacon_name': beaconName,
        'is_active': isActive,
      },
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<void> deleteBeacon(
    int beaconId,
  ) async {
    await _apiClient.dio.delete(
      '/beacons/$beaconId',
    );
  }
}