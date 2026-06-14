// mobile_app/lib/features/faculty/models/attendance_evidence.dart

class AttendanceEvidence {
  final List<BleEvidence> ble;
  final GpsEvidence? gps;

  final String? clientTimestamp;
  final String? serverReceivedTimestamp;

  const AttendanceEvidence({
    required this.ble,
    required this.gps,
    required this.clientTimestamp,
    required this.serverReceivedTimestamp,
  });

  factory AttendanceEvidence.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttendanceEvidence(
      ble: (json['ble'] as List<dynamic>? ?? [])
          .map(
            (item) => BleEvidence.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      gps: json['gps'] != null
          ? GpsEvidence.fromJson(
              json['gps']
                  as Map<String, dynamic>,
            )
          : null,
      clientTimestamp:
          json['client_timestamp']
              ?.toString(),
      serverReceivedTimestamp:
          json['server_received_timestamp']
              ?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ble': ble
          .map(
            (e) => e.toJson(),
          )
          .toList(),
      'gps': gps?.toJson(),
      'client_timestamp':
          clientTimestamp,
      'server_received_timestamp':
          serverReceivedTimestamp,
    };
  }
}

class BleEvidence {
  final Map<String, dynamic>? beaconData;
  final String? clientTimestamp;
  final String? serverReceivedTimestamp;

  const BleEvidence({
    required this.beaconData,
    required this.clientTimestamp,
    required this.serverReceivedTimestamp,
  });

  factory BleEvidence.fromJson(
    Map<String, dynamic> json,
  ) {
    return BleEvidence(
      beaconData:
          json['beacon_data']
              as Map<String, dynamic>?,
      clientTimestamp:
          json['client_timestamp']
              ?.toString(),
      serverReceivedTimestamp:
          json['server_received_timestamp']
              ?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'beacon_data': beaconData,
      'client_timestamp': clientTimestamp,
      'server_received_timestamp':
          serverReceivedTimestamp,
    };
  }
}

class GpsEvidence {
  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final double? distanceFromClassroomMeters;
  final String? validationResult;
  final String? validationReason;

  const GpsEvidence({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.distanceFromClassroomMeters,
    required this.validationResult,
    required this.validationReason,
  });

  factory GpsEvidence.fromJson(
    Map<String, dynamic> json,
  ) {
    return GpsEvidence(
      latitude:
          (json['latitude'] as num)
              .toDouble(),
      longitude:
          (json['longitude'] as num)
              .toDouble(),
      accuracyMeters:
          (json['accuracy_meters'] as num)
              .toDouble(),
      distanceFromClassroomMeters:
          (json['distance_from_classroom_meters']
                  as num?)
              ?.toDouble(),
      validationResult:
          json['validation_result']
              ?.toString(),
      validationReason:
          json['validation_reason']
              ?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy_meters': accuracyMeters,
      'distance_from_classroom_meters':
          distanceFromClassroomMeters,
      'validation_result':
          validationResult,
      'validation_reason':
          validationReason,
    };
  }
}