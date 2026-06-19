# Database Integrity Validation

## Objective

Verify that all critical relationships and foreign-key dependencies are correctly maintained throughout the system.

---

# Check 1 — Attendance → Session

### Validation

Every attendance record references a valid attendance session.

### Evidence

* attendance_record.png
* attendance_session_integrity.png

### Result

PASS

---

# Check 2 — Attendance → BLE Evidence

### Validation

Attendance records contain associated BLE evidence.

### Evidence

* attendance_ble_evidence.png

### Result

PASS

---

# Check 3 — Attendance → GPS Evidence

### Validation

Attendance records contain associated GPS evidence.

### Evidence

* attendance_gps_evidence.png

### Result

PASS

---

# Check 4 — Claim → Attendance

### Validation

Every attendance claim references a valid attendance record.

### Evidence

* claim_record.png
* claim_attendance_integrity.png

### Result

PASS

---

# Check 5 — Enrollment Integrity

### Validation

Enrollment records reference valid students and courses.

### Evidence

* student_enrollment.png

### Result

PASS

---

# Check 6 — Faculty Assignment Integrity

### Validation

Faculty assignments reference valid faculty and course records.

### Evidence

* faculty_assignment.png

### Result

PASS

---

# Check 7 — Beacon Assignment Integrity

### Validation

Trusted BLE beacons are associated with valid classrooms.

### Evidence

* beacon_assignment.png

### Result

PASS

---

# Check 8 — Device Binding Integrity

### Validation

Devices are associated with valid user accounts.

### Evidence

* device_binding.png

### Result

PASS

---

# Check 9 — Registration Session Integrity

### Validation

Registration sessions are linked to valid courses and faculty members.

### Evidence

* registration_sessions.png

### Result

PASS

---

# Check 10 — Registration Request Integrity

### Validation

Registration requests reference valid students and registration sessions.

### Evidence

* registration_requests.png

### Result

PASS

---

# Check 11 — Audit Log Integrity

### Validation

Faculty actions are recorded successfully.

### Evidence

* faculty_action_logs.png

### Result

PASS

---

# Overall Result

Database Integrity Status: PASS

All tested relationships and dependencies were validated successfully.
