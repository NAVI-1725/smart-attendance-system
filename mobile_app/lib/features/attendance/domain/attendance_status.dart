// mobile_app/lib/features/attendance/domain/attendance_status.dart

enum AttendanceStatus {
  confirmed,
  flagged,
  absent,
  claimed,
  modified,
  finalized,
}

extension AttendanceStatusX on AttendanceStatus {
  String get value {
    switch (this) {
      case AttendanceStatus.confirmed:
        return 'CONFIRMED';
      case AttendanceStatus.flagged:
        return 'FLAGGED';
      case AttendanceStatus.absent:
        return 'ABSENT';
      case AttendanceStatus.claimed:
        return 'CLAIMED';
      case AttendanceStatus.modified:
        return 'MODIFIED';
      case AttendanceStatus.finalized:
        return 'FINALIZED';
    }
  }

  static AttendanceStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return AttendanceStatus.confirmed;
      case 'FLAGGED':
        return AttendanceStatus.flagged;
      case 'ABSENT':
        return AttendanceStatus.absent;
      case 'CLAIMED':
        return AttendanceStatus.claimed;
      case 'MODIFIED':
        return AttendanceStatus.modified;
      case 'FINALIZED':
        return AttendanceStatus.finalized;
      default:
        throw ArgumentError('Unknown attendance status: $status');
    }
  }
}

// UI-only display label extension.
// Does NOT affect backend values, parsing, or domain logic.
// Backend remains the single source of truth.
extension AttendanceStatusLabel on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.confirmed:
        return 'Confirmed';
      case AttendanceStatus.flagged:
        return 'Flagged';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.claimed:
        return 'Claimed';
      case AttendanceStatus.modified:
        return 'Modified';
      case AttendanceStatus.finalized:
        return 'Finalized';
    }
  }
}
