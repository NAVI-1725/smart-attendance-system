// mobile_app/lib/features/admin/models/classroom.dart

class Classroom {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final int gpsRadiusMeters;

  const Classroom({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.gpsRadiusMeters,
  });

  factory Classroom.fromJson(
    Map<String, dynamic> json,
  ) {
    return Classroom(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude:
          (json['latitude'] as num)
              .toDouble(),
      longitude:
          (json['longitude'] as num)
              .toDouble(),
      gpsRadiusMeters:
          json['gps_radius_meters']
              as int,
    );
  }
}