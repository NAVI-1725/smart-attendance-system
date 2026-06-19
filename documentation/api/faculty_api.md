# Faculty API Documentation

## Module Overview

The Faculty API manages attendance sessions, attendance review, attendance approval/rejection, registration sessions, and attendance export operations.

---

# 1. Start Attendance Session

## Endpoint

```http
POST /api/v1/sessions/start
```

## Description

Creates a new attendance session for a selected course.

## Authentication

Faculty JWT Required

## Response

```json
{
  "session_id": 32,
  "status": "ACTIVE"
}
```

## Evidence

* start_session_api.png

---

# 2. Review Flagged Attendance

## Endpoint

```http
GET /api/v1/faculty/attendance/pending
```

## Description

Returns attendance records requiring manual review.

## Evidence

* review_attendance_api.png

---

# 3. Confirm Attendance

## Description

Faculty may manually confirm attendance after reviewing evidence.

## Evidence Reviewed

* BLE Evidence
* GPS Evidence
* Session Information

## Result

Attendance status updated to:

```text
CONFIRMED
```

## Evidence

* FAC_04_attendance_confirmed.png

---

# 4. Reject Attendance

## Endpoint

```http
POST /api/v1/faculty/attendance/{id}/reject
```

## Description

Rejects an attendance submission.

## Evidence

* reject_attendance_api.png

---

# 5. Registration Session Management

## Features

* Create Registration Session
* Close Registration Session
* View Registration Requests
* Approve Requests
* Reject Requests

## Evidence

* FAC_08_registration_session_active.png
* FAC_09_registration_request_pending.png
* FAC_10_registration_request_approved.png

---

# 6. Attendance Export

## Description

Exports attendance records as CSV.

## Export Format

```text
attendance_COURSECODE.csv
```

## Evidence

* FAC_13_export_attendance_csv.png

---

# Database Tables Used

* attendance
* attendance_sessions
* faculty_action_logs
* course_registration_sessions
* course_registration_requests

---

# Security Features

* Role-Based Authorization
* Faculty Ownership Validation
* Attendance Audit Logging
* Claim Review Controls
