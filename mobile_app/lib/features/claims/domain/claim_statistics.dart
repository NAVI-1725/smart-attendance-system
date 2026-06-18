// mobile_app/lib/features/claims/domain/claim_statistics.dart

class ClaimStatistics {
  final int total;

  final int pending;

  final int approved;

  final int rejected;

  const ClaimStatistics({
    required this.total,
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  factory ClaimStatistics.fromJson(
    Map<String, dynamic> json,
  ) {
    return ClaimStatistics(
      total: json['total'] as int,
      pending: json['pending'] as int,
      approved: json['approved'] as int,
      rejected: json['rejected'] as int,
    );
  }
}