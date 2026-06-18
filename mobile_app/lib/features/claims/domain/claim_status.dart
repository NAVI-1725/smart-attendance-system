// mobile_app/lib/features/claims/domain/claim_status.dart

enum ClaimStatus {
  pending,
  approved,
  rejected,
}

ClaimStatus claimStatusFromApi(
  String value,
) {
  switch (value.toUpperCase()) {
    case 'PENDING':
      return ClaimStatus.pending;

    case 'APPROVED':
      return ClaimStatus.approved;

    case 'REJECTED':
      return ClaimStatus.rejected;

    default:
      throw ArgumentError(
        'Unknown ClaimStatus: $value',
      );
  }
}