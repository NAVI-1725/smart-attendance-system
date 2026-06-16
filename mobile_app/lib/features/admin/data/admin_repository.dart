// mobile_app/lib/features/admin/data/admin_repository.dart

import '../models/admin_beacon.dart';
import '../models/admin_course.dart';
import '../models/admin_faculty.dart';
import '../models/admin_student.dart';
import '../models/classroom.dart';
import '../models/enrollment.dart';
import '../models/faculty_course_assignment.dart';
import 'admin_api_service.dart';

class AdminRepository {
  final AdminApiService _apiService;

  AdminRepository(this._apiService);

  Future<Map<String, dynamic>>
      getSystemSummary() {
    return _apiService.getSystemSummary();
  }

  Future<List<AdminStudent>>
      getStudents() async {
    final data =
        await _apiService.getStudents();

    return data
        .map(
          (item) =>
              AdminStudent.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<AdminStudent>
      createStudent({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final data =
        await _apiService.createStudent(
      fullName: fullName,
      email: email,
      password: password,
    );

    return AdminStudent.fromJson(data);
  }

  Future<AdminStudent>
      getStudent(
    int studentId,
  ) async {
    final data =
        await _apiService.getStudent(
      studentId,
    );

    return AdminStudent.fromJson(data);
  }

  Future<AdminStudent>
      updateStudent({
    required int studentId,
    required String fullName,
    required String email,
    required bool isActive,
  }) async {
    final data =
        await _apiService.updateStudent(
      studentId: studentId,
      fullName: fullName,
      email: email,
      isActive: isActive,
    );

    return AdminStudent.fromJson(data);
  }

  Future<void> deleteStudent(
    int studentId,
  ) {
    return _apiService.deleteStudent(
      studentId,
    );
  }

  Future<Map<String, dynamic>>
      importStudents(
    String filePath,
  ) {
    return _apiService.importStudents(
      filePath,
    );
  }

  Future<List<AdminFaculty>>
      getFaculty() async {
    final data =
        await _apiService.getFaculty();

    return data
        .map(
          (item) =>
              AdminFaculty.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<AdminFaculty>
      createFaculty({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final data =
        await _apiService.createFaculty(
      fullName: fullName,
      email: email,
      password: password,
    );

    return AdminFaculty.fromJson(data);
  }

  Future<AdminFaculty>
      getFacultyMember(
    int facultyId,
  ) async {
    final data =
        await _apiService.getFacultyMember(
      facultyId,
    );

    return AdminFaculty.fromJson(data);
  }

  Future<AdminFaculty>
      updateFaculty({
    required int facultyId,
    required String fullName,
    required String email,
    required bool isActive,
  }) async {
    final data =
        await _apiService.updateFaculty(
      facultyId: facultyId,
      fullName: fullName,
      email: email,
      isActive: isActive,
    );

    return AdminFaculty.fromJson(data);
  }

  Future<void> deleteFaculty(
    int facultyId,
  ) {
    return _apiService.deleteFaculty(
      facultyId,
    );
  }

  Future<Map<String, dynamic>>
      importFaculty(
    String filePath,
  ) {
    return _apiService.importFaculty(
      filePath,
    );
  }

  Future<List<AdminCourse>>
      getCourses() async {
    final data =
        await _apiService.getCourses();

    return data
        .map(
          (item) =>
              AdminCourse.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<AdminCourse>
      createCourse({
    required String courseCode,
    required String courseName,
  }) async {
    final data =
        await _apiService.createCourse(
      courseCode: courseCode,
      courseName: courseName,
    );

    return AdminCourse.fromJson(data);
  }

  Future<AdminCourse>
      getCourse(
    int courseId,
  ) async {
    final data =
        await _apiService.getCourse(
      courseId,
    );

    return AdminCourse.fromJson(data);
  }

  Future<AdminCourse>
      updateCourse({
    required int courseId,
    required String courseCode,
    required String courseName,
  }) async {
    final data =
        await _apiService.updateCourse(
      courseId: courseId,
      courseCode: courseCode,
      courseName: courseName,
    );

    return AdminCourse.fromJson(data);
  }

  Future<void> deleteCourse(
    int courseId,
  ) {
    return _apiService.deleteCourse(
      courseId,
    );
  }

  Future<List<FacultyCourseAssignment>>
      getFacultyCourseAssignments() async {
    final data =
        await _apiService
            .getFacultyCourseAssignments();

    return data
        .map(
          (item) =>
              FacultyCourseAssignment
                  .fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void>
      createFacultyCourseAssignment({
    required int facultyId,
    required int courseId,
  }) async {
    await _apiService
        .createFacultyCourseAssignment(
      facultyId: facultyId,
      courseId: courseId,
    );
  }

  Future<void>
      deleteFacultyCourseAssignment(
    int assignmentId,
  ) {
    return _apiService
        .deleteFacultyCourseAssignment(
      assignmentId,
    );
  }

  Future<List<Enrollment>>
      getEnrollments() async {
    final data =
        await _apiService.getEnrollments();

    return data
        .map(
          (item) => Enrollment.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> createEnrollment({
    required int studentId,
    required int courseId,
  }) async {
    await _apiService.createEnrollment(
      studentId: studentId,
      courseId: courseId,
    );
  }

  Future<void> deleteEnrollment(
    int enrollmentId,
  ) {
    return _apiService.deleteEnrollment(
      enrollmentId,
    );
  }

  Future<List<Classroom>>
      getClassrooms() async {
    final data =
        await _apiService.getClassrooms();

    return data
        .map(
          (item) => Classroom.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<Classroom>
      createClassroom({
    required String name,
    required double latitude,
    required double longitude,
    required int gpsRadiusMeters,
  }) async {
    final data =
        await _apiService.createClassroom(
      name: name,
      latitude: latitude,
      longitude: longitude,
      gpsRadiusMeters:
          gpsRadiusMeters,
    );

    return Classroom.fromJson(data);
  }

  Future<Classroom>
      getClassroom(
    int classroomId,
  ) async {
    final data =
        await _apiService.getClassroom(
      classroomId,
    );

    return Classroom.fromJson(data);
  }

  Future<Classroom>
      updateClassroom({
    required int classroomId,
    required String name,
    required double latitude,
    required double longitude,
    required int gpsRadiusMeters,
  }) async {
    final data =
        await _apiService.updateClassroom(
      classroomId: classroomId,
      name: name,
      latitude: latitude,
      longitude: longitude,
      gpsRadiusMeters:
          gpsRadiusMeters,
    );

    return Classroom.fromJson(data);
  }

  Future<void> deleteClassroom(
    int classroomId,
  ) {
    return _apiService.deleteClassroom(
      classroomId,
    );
  }

  Future<List<AdminBeacon>>
      getBeacons() async {
    final data =
        await _apiService.getBeacons();

    return data
        .map(
          (item) => AdminBeacon.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<AdminBeacon>
      createBeacon({
    required int classroomId,
    required String beaconUuid,
    String? beaconName,
  }) async {
    final data =
        await _apiService.createBeacon(
      classroomId: classroomId,
      beaconUuid: beaconUuid,
      beaconName: beaconName,
    );

    return AdminBeacon.fromJson(data);
  }

  Future<AdminBeacon>
      getBeacon(
    int beaconId,
  ) async {
    final data =
        await _apiService.getBeacon(
      beaconId,
    );

    return AdminBeacon.fromJson(data);
  }

  Future<AdminBeacon>
      updateBeacon({
    required int beaconId,
    required int classroomId,
    required String beaconUuid,
    String? beaconName,
    required bool isActive,
  }) async {
    final data =
        await _apiService.updateBeacon(
      beaconId: beaconId,
      classroomId: classroomId,
      beaconUuid: beaconUuid,
      beaconName: beaconName,
      isActive: isActive,
    );

    return AdminBeacon.fromJson(data);
  }

  Future<void> deleteBeacon(
    int beaconId,
  ) {
    return _apiService.deleteBeacon(
      beaconId,
    );
  }
}