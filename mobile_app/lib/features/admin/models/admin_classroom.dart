// mobile_app/lib/features/admin/models/admin_classroom.dart

class AdminClassroom {
  final int id;

  final String name;

  final int facultyId;

  final double latitude;

  final double longitude;

  final int gpsRadiusMeters;

  const AdminClassroom({
    required this.id,
    required this.name,
    required this.facultyId,
    required this.latitude,
    required this.longitude,
    required this.gpsRadiusMeters,
  });

  factory AdminClassroom.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminClassroom(
      id: json['id'] as int,
      name: json['name'] as String,
      facultyId: json['faculty_id'] as int,
      latitude:
          (json['latitude'] as num).toDouble(),
      longitude:
          (json['longitude'] as num).toDouble(),
      gpsRadiusMeters:
          json['gps_radius_meters'] as int,
    );
  }
}