# Attendance API Documentation

## Module Overview

The Attendance API manages attendance session discovery, attendance submission, BLE evidence validation, GPS validation, and attendance history retrieval.

---

# 1. Get Active Sessions

## Endpoint

```http
GET /api/v1/sessions/my-active-sessions
```

## Description

Returns all active attendance sessions available to the authenticated student.

## Authentication

JWT Required

## Response

```json
[
  {
    "session_id": 32,
    "course_code": "CSE201",
    "course_name": "Data Structuress",
    "faculty_name": "Faculty 1",
    "expires_at": "2026-06-19T17:13:12Z"
  }
]
```

## Evidence

* active_sessions_api.png

---

# 2. Submit Attendance

## Endpoint

```http
POST /api/v1/attendance/submit
```

## Description

Submits attendance evidence collected from BLE and GPS validation.

## Authentication

JWT Required

## Request Data

```json
{
  "session_id": 32,
  "ble_evidence": [],
  "gps_evidence": {}
}
```

## Response

```json
{
  "attendance_id": 58,
  "status": "CONFIRMED"
}
```

## Evidence

* submit_attendance_api.png

---

# 3. BLE Evidence Validation

## Description

BLE evidence is validated using:

* RSSI Threshold Validation
* Nonce Validation
* Signature Validation
* Replay Protection

## Security Controls

* Nonce Cache
* HMAC Signature Verification
* Multi-Beacon Validation

---

# 4. GPS Evidence Validation

## Description

GPS coordinates are validated against classroom geofence parameters.

## Validation Criteria

* Latitude
* Longitude
* Accuracy
* Distance from Classroom
* Geofence Radius

---

# 5. Attendance History

## Description

Allows students to review previously submitted attendance records.

## Features

* Attendance Status
* Timestamp
* Course Information
* Claim Status

## Evidence

* STU_04_attendance_history.png

---

# Database Tables Used

* attendance
* attendance_ble_evidence
* attendance_gps_evidence
* attendance_sessions
* attendance_ble_nonce_cache

---

# Security Features

* JWT Authentication
* BLE Validation
* GPS Validation
* Replay Protection
* Device Binding Enforcement
