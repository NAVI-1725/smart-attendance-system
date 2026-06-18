// mobile_app/lib/features/faculty/models/registration_request.dart

enum RegistrationRequestStatus {
  pending,
  approved,
  rejected;

  static RegistrationRequestStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'APPROVED':
        return RegistrationRequestStatus.approved;
      case 'REJECTED':
        return RegistrationRequestStatus.rejected;
      default:
        return RegistrationRequestStatus.pending;
    }
  }

  String get label {
    switch (this) {
      case RegistrationRequestStatus.pending:
        return 'PENDING';
      case RegistrationRequestStatus.approved:
        return 'APPROVED';
      case RegistrationRequestStatus.rejected:
        return 'REJECTED';
    }
  }

  bool get isPending => this == RegistrationRequestStatus.pending;
  bool get isApproved => this == RegistrationRequestStatus.approved;
  bool get isRejected => this == RegistrationRequestStatus.rejected;
}

class RegistrationRequest {
  final int id;
  final int studentId;
  final String studentName;
  final RegistrationRequestStatus status;

  const RegistrationRequest({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.status,
  });

  factory RegistrationRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return RegistrationRequest(
      id: json['id'] as int,
      studentId: json['student_id'] as int,
      studentName: json['student_name'] as String,
      status: RegistrationRequestStatus.fromString(
        json['status'] as String,
      ),
    );
  }
}