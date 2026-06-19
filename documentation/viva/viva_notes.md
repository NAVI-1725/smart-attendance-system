# Viva Preparation Notes

## 1. Why BLE?

### Answer

Bluetooth Low Energy (BLE) is used to verify physical proximity between the student and classroom beacon.

Advantages:

* Indoor friendly
* Low power consumption
* Difficult to spoof compared to QR attendance
* Provides proximity evidence

---

## 2. Why GPS?

### Answer

GPS provides location validation to ensure students are within the classroom geofence.

Advantages:

* Additional verification layer
* Supports multi-evidence attendance validation
* Helps identify suspicious attendance submissions

---

## 3. Why Device Binding?

### Answer

Device binding prevents proxy attendance.

Each user account is linked to a single registered device.

Benefits:

* Reduces credential sharing
* Improves attendance integrity
* Strengthens authentication

---

## 4. Why Faculty Review?

### Answer

Automated validation may occasionally produce false positives or false negatives.

Faculty review provides:

* Human verification
* Fair attendance decisions
* Academic accountability

---

## 5. Why Claims?

### Answer

Claims provide a formal appeal mechanism.

Students can request review of attendance decisions.

Benefits:

* Transparency
* Fairness
* Auditability

---

## 6. Why Course-Based Architecture?

### Answer

Faculty teach courses, not classrooms.

A course-based model provides:

* Better academic representation
* Multiple classrooms per course
* Flexible scheduling

---

## 7. Why Not Auto-Reject GPS Failures?

### Answer

GPS accuracy can be unreliable indoors.

Instead of automatic rejection:

* Attendance is flagged
* Faculty reviews evidence
* Final decision is made manually

---

## 8. How Replay Protection Works?

### Answer

Each BLE transmission contains a nonce.

The nonce is stored in:

attendance_ble_nonce_cache

If the same nonce appears again:

* Submission is rejected
* Replay attack prevented

---

## 9. How Signature Validation Works?

### Answer

BLE beacon broadcasts contain a signed payload.

The backend validates the signature using shared beacon secrets.

Benefits:

* Prevents beacon spoofing
* Verifies beacon authenticity

---

## 10. What Security Features Exist?

### Answer

The system includes:

* JWT Authentication
* Device Binding
* BLE Validation
* GPS Validation
* Replay Protection
* Faculty Review
* Claims Management
* Audit Logs
* Beacon Authentication

---

## 11. What Evidence Is Stored?

### Answer

Attendance records store:

* Student information
* Session information
* BLE evidence
* GPS evidence
* Validation results
* Faculty review outcome

---

## 12. Future Enhancements

Possible future improvements:

* Offline attendance support
* Push notifications
* Advanced analytics
* Face recognition integration
* Multi-campus deployment

---

# Final Viva Summary

Project Title:

Smart Hybrid Attendance System

Core Technologies:

* Flutter
* FastAPI
* PostgreSQL
* BLE Beacons
* GPS Validation
* JWT Authentication

Primary Contribution:

A multi-evidence attendance verification system combining BLE proximity validation, GPS verification, device binding, faculty review, and claims management to improve attendance authenticity and security.
