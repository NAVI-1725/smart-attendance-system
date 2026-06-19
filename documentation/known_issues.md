# Known Issues and Limitations

## Overview

This document records the known limitations, assumptions, and non-critical issues identified during the development and testing of the Smart Hybrid Attendance System.

No critical defects affecting core functionality were identified during final validation.

---

# Known Limitations

## KI-01 Internet Connectivity Required

### Description

The current implementation requires an active internet connection for:

* User authentication
* Session discovery
* Attendance submission
* Claims management
* Administrative operations

### Impact

Users cannot perform attendance operations while offline.

### Severity

Low

### Planned Resolution

Offline attendance synchronization may be considered in future versions.

---

## KI-02 BLE Hardware Dependency

### Description

The attendance verification process depends on the availability of configured BLE beacons within the classroom.

### Impact

Attendance cannot be validated if beacon hardware is unavailable or powered off.

### Severity

Medium

### Planned Resolution

Additional fallback verification mechanisms may be introduced in future releases.

---

## KI-03 GPS Accuracy Variations

### Description

GPS accuracy may fluctuate due to:

* Indoor environments
* Building structures
* Device hardware differences
* Environmental conditions

### Impact

Valid students may occasionally receive FLAGGED attendance status.

### Severity

Low

### Current Mitigation

Faculty review workflow and claims management provide correction mechanisms.

---

## KI-04 Single Device Registration Policy

### Description

Each user account may be associated with only one active device at a time.

### Impact

Users changing devices must request administrator intervention for device unbinding.

### Severity

Low

### Reason

Implemented intentionally to reduce proxy attendance and account sharing.

---

## KI-05 Limited Hardware Testing

### Description

Testing was performed using a limited number of Android devices and BLE beacon units.

### Impact

Performance characteristics may vary across different hardware platforms.

### Severity

Low

### Planned Resolution

Extended device compatibility testing in future deployments.

---

## KI-06 Classroom Deployment Assumption

### Description

The system assumes:

* BLE beacons are correctly installed.
* Classroom coordinates are correctly configured.
* Geofence parameters are valid.

### Impact

Incorrect classroom configuration may affect attendance validation.

### Severity

Medium

### Mitigation

Administrative verification procedures are required during deployment.

---

# Deferred Features

The following features were intentionally excluded from the current project scope:

* Offline Attendance Synchronization
* Push Notifications
* Analytics Dashboard
* Advanced Reporting
* Email Notifications
* Face Recognition Attendance
* AI-Based Attendance Verification
* Multi-Campus Deployment Support

These features may be considered for future enhancement.

---

# Final Assessment

All core project objectives were successfully achieved.

The identified issues do not affect the correctness, security, or reliability of the primary attendance workflow.

System Status: STABLE

Validation Status: PASS

Deployment Readiness: APPROVED
