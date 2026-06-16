// mobile_app/lib/features/admin/models/admin_beacon.dart

class AdminBeacon {
  final int id;

  final int classroomId;

  final String beaconUuid;

  final String? beaconName;

  final bool isActive;

  const AdminBeacon({
    required this.id,
    required this.classroomId,
    required this.beaconUuid,
    required this.beaconName,
    required this.isActive,
  });

  factory AdminBeacon.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminBeacon(
      id: json['id'] as int,
      classroomId:
          json['classroom_id'] as int,
      beaconUuid:
          json['beacon_uuid'] as String,
      beaconName:
          json['beacon_name'] as String?,
      isActive:
          json['is_active'] as bool,
    );
  }
}