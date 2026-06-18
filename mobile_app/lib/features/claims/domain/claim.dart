// mobile_app/lib/features/claims/domain/claim.dart

import 'claim_status.dart';

class Claim {
  final int id;

  final int attendanceId;

  final int studentId;

  final String reason;

  final ClaimStatus status;

  final DateTime createdAt;

  final String? resolutionReason;

  final DateTime? resolvedAt;

  const Claim({
    required this.id,
    required this.attendanceId,
    required this.studentId,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.resolutionReason,
    this.resolvedAt,
  });

  factory Claim.fromJson(
    Map<String, dynamic> json,
  ) {
    return Claim(
      id: json['id'] as int,
      attendanceId: json['attendance_id'] as int,
      studentId: json['student_id'] as int,
      reason: json['reason'] as String,
      status: claimStatusFromApi(
        json['status'] as String,
      ),
      createdAt: DateTime.parse(
        json['created_at'] as String,
      ),
      resolutionReason:
          json['claim_resolution_reason'] as String?,
      resolvedAt:
          json['claim_resolved_at'] != null
              ? DateTime.parse(
                  json['claim_resolved_at']
                      as String,
                )
              : null,
    );
  }
}