// mobile_app\lib\features\attendance\domain\session_status.dart
enum SessionStatus {
  created,
  active,
  closed,
  finalized,
}

extension SessionStatusX on SessionStatus {
  String get value {
    switch (this) {
      case SessionStatus.created:
        return 'CREATED';
      case SessionStatus.active:
        return 'ACTIVE';
      case SessionStatus.closed:
        return 'CLOSED';
      case SessionStatus.finalized:
        return 'FINALIZED';
    }
  }

  static SessionStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'CREATED':
        return SessionStatus.created;
      case 'ACTIVE':
        return SessionStatus.active;
      case 'CLOSED':
        return SessionStatus.closed;
      case 'FINALIZED':
        return SessionStatus.finalized;
      default:
        throw ArgumentError('Unknown session status: $status');
    }
  }
}
