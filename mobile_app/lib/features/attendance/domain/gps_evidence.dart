// mobile_app/lib/features/attendance/domain/gps_evidence.dart

class GPSEvidence {
  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime capturedAt;

  const GPSEvidence({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.capturedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy_meters': accuracyMeters,
      'captured_at': capturedAt.toUtc().toIso8601String(),
    };
  }
}