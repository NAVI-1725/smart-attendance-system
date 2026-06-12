// mobile_app/lib/core/services/ble/ble_beacon_payload.dart

class BleBeaconPayload {
  final String beaconId;
  final String nonce;
  final int timestamp;
  final String signature;

  const BleBeaconPayload({
    required this.beaconId,
    required this.nonce,
    required this.timestamp,
    required this.signature,
  });

  factory BleBeaconPayload.fromJson(
    Map<String, dynamic> json,
  ) {
    return BleBeaconPayload(
      beaconId: json['beacon_id'] as String,
      nonce: json['nonce'] as String,
      timestamp: json['timestamp'] as int,
      signature: json['signature'] as String,
    );
  }
}