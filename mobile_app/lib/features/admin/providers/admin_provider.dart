// mobile_app/lib/features/admin/providers/admin_provider.dart

import 'package:flutter/foundation.dart';

import '../data/admin_repository.dart';
import '../models/admin_beacon.dart';
import '../models/admin_course.dart';
import '../models/admin_faculty.dart';
import '../models/admin_student.dart';
import '../models/classroom.dart';
import '../models/enrollment.dart';
import '../models/faculty_course_assignment.dart';
import '../models/system_summary.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository _repository;

  AdminProvider(this._repository);

  bool isLoading = false;

  SystemSummary? systemSummary;

  List<AdminStudent> students = [];

  List<AdminFaculty> faculty = [];

  List<AdminCourse> courses = [];

  List<FacultyCourseAssignment>
      facultyCourseAssignments = [];

  List<Enrollment> enrollments = [];

  List<Classroom> classrooms = [];

  List<AdminBeacon> beacons = [];

  Future<void> loadSystemSummary() async {
    isLoading = true;
    notifyListeners();

    try {
      final data =
          await _repository.getSystemSummary();

      systemSummary =
          SystemSummary.fromJson(data);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStudents() async {
    isLoading = true;
    notifyListeners();

    try {
      students =
          await _repository.getStudents();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createStudent({
    required String fullName,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repository.createStudent(
        fullName: fullName,
        email: email,
        password: password,
      );

      await loadStudents();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStudent({
    required int studentId,
    required String fullName,
    required String email,
    required bool isActive,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repository.updateStudent(
        studentId: studentId,
        fullName: fullName,
        email: email,
        isActive: isActive,
      );

      await loadStudents();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteStudent(
    int studentId,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repository.deleteStudent(
        studentId,
      );

      await loadStudents();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Returns the import summary:
  /// { "created": int, "skipped": int, "errors": List }
  /// Reloads the student list on success.
  Future<Map<String, dynamic>>
      importStudents(
    String filePath,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      final result =
          await _repository.importStudents(
        filePath,
      );

      await loadStudents();

      return result;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFaculty() async {
    isLoading = true;
    notifyListeners();

    try {
      faculty =
          await _repository.getFaculty();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createFaculty({
    required String fullName,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repository.createFaculty(
        fullName: fullName,
        email: email,
        password: password,
      );

      await loadFaculty();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateFaculty({
    required int facultyId,
    required String fullName,
    required String email,
    required bool isActive,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repository.updateFaculty(
        facultyId: facultyId,
        fullName: fullName,
        email: email,
        isActive: isActive,
      );

      await loadFaculty();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteFaculty(
    int facultyId,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repository.deleteFaculty(
        facultyId,
      );

      await loadFaculty();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Returns the import summary:
  /// { "created": int, "skipped": int, "errors": List }
  /// Reloads the faculty list on success.
  Future<Map<String, dynamic>>
      importFaculty(
    String filePath,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      final result =
          await _repository.importFaculty(
        filePath,
      );

      await loadFaculty();

      return result;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCourses() async {
    isLoading = true;
    notifyListeners();

    try {
      courses =
          await _repository.getCourses();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCourse({
    required String courseCode,
    required String courseName,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repository.createCourse(
        courseCode: courseCode,
        courseName: courseName,
      );

      await loadCourses();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCourse({
    required int courseId,
    required String courseCode,
    required String courseName,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repository.updateCourse(
        courseId: courseId,
        courseCode: courseCode,
        courseName: courseName,
      );

      await loadCourses();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCourse(
    int courseId,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repository.deleteCourse(
        courseId,
      );

      await loadCourses();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void>
      loadFacultyCourseAssignments() async {
    isLoading = true;
    notifyListeners();

    try {
      facultyCourseAssignments =
          await _repository
              .getFacultyCourseAssignments();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void>
      createFacultyCourseAssignment({
    required int facultyId,
    required int courseId,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repository
          .createFacultyCourseAssignment(
        facultyId: facultyId,
        courseId: courseId,
      );

      await loadFacultyCourseAssignments();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void>
      deleteFacultyCourseAssignment(
    int assignmentId,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repository
          .deleteFacultyCourseAssignment(
        assignmentId,
      );

      await loadFacultyCourseAssignments();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEnrollments() async {
    isLoading = true;
    notifyListeners();

    try {
      enrollments =
          await _repository.getEnrollments();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createEnrollment({
    required int studentId,
    required int courseId,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repository.createEnrollment(
        studentId: studentId,
        courseId: courseId,
      );

      await loadEnrollments();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteEnrollment(
    int enrollmentId,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repository.deleteEnrollment(
        enrollmentId,
      );

      await loadEnrollments();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadClassrooms() async {
    isLoading = true;
    notifyListeners();

    try {
      classrooms =
          await _repository.getClassrooms();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createClassroom({
    required String name,
    required double latitude,
    required double longitude,
    required int gpsRadiusMeters,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repository.createClassroom(
        name: name,
        latitude: latitude,
        longitude: longitude,
        gpsRadiusMeters:
            gpsRadiusMeters,
      );

      await loadClassrooms();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateClassroom({
    required int classroomId,
    required String name,
    required double latitude,
    required double longitude,
    required int gpsRadiusMeters,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repository.updateClassroom(
        classroomId: classroomId,
        name: name,
        latitude: latitude,
        longitude: longitude,
        gpsRadiusMeters:
            gpsRadiusMeters,
      );

      await loadClassrooms();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteClassroom(
    int classroomId,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repository.deleteClassroom(
        classroomId,
      );

      await loadClassrooms();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBeacons() async {
    isLoading = true;
    notifyListeners();

    try {
      beacons =
          await _repository.getBeacons();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createBeacon({
    required int classroomId,
    required String beaconUuid,
    String? beaconName,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repository.createBeacon(
        classroomId: classroomId,
        beaconUuid: beaconUuid,
        beaconName: beaconName,
      );

      await loadBeacons();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBeacon({
    required int beaconId,
    required int classroomId,
    required String beaconUuid,
    String? beaconName,
    required bool isActive,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repository.updateBeacon(
        beaconId: beaconId,
        classroomId: classroomId,
        beaconUuid: beaconUuid,
        beaconName: beaconName,
        isActive: isActive,
      );

      await loadBeacons();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBeacon(
    int beaconId,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repository.deleteBeacon(
        beaconId,
      );

      await loadBeacons();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}