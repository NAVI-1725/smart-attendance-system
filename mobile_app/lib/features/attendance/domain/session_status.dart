// mobile_app/lib/features/attendance/domain/session_status.dart

enum SessionStatus {
  active,
  closed,
  expired,
}

extension SessionStatusX on SessionStatus {
  String get value {
    switch (this) {
      case SessionStatus.active:
        return 'ACTIVE';
      case SessionStatus.closed:
        return 'CLOSED';
      case SessionStatus.expired:
        return 'EXPIRED';
    }
  }

  static SessionStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return SessionStatus.active;
      case 'CLOSED':
        return SessionStatus.closed;
      case 'EXPIRED':
        return SessionStatus.expired;
      default:
        throw ArgumentError('Unknown session status: $status');
    }
  }
}