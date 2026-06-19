# Claims API Documentation

## Module Overview

The Claims API provides a controlled appeal mechanism for students whose attendance records have been rejected or flagged. The module allows students to submit claims and enables faculty members to review, approve, or reject those claims.

The Claims Management System improves fairness, transparency, and auditability within the attendance workflow.

---

# Claims Workflow

```text
Attendance Rejected / Flagged
            ↓
Student Creates Claim
            ↓
Claim Stored
            ↓
Faculty Reviews Claim
            ↓
Approve or Reject
            ↓
Attendance Updated
```

---

# 1. Submit Claim

## Endpoint

```http
POST /api/v1/claims
```

## Description

Allows a student to submit an appeal against an attendance decision.

A claim can only be created for an eligible attendance record.

## Authentication

Student JWT Required

## Request Example

```json
{
  "attendance_id": 65,
  "reason": "I was present in class but my attendance was incorrectly flagged."
}
```

## Success Response

```json
{
  "claim_id": 1,
  "status": "PENDING"
}
```

## Validation Rules

* Student must own the attendance record.
* Attendance record must exist.
* Duplicate claims are not allowed.
* Claim reason is required.

## Evidence

* create_claim_api.png
* STU_05_my_claims.png

---

# 2. View Student Claims

## Description

Allows students to review previously submitted claims.

## Information Returned

* Claim ID
* Attendance ID
* Status
* Reason
* Resolution Reason
* Creation Timestamp
* Resolution Timestamp

## Possible Status Values

```text
PENDING
APPROVED
REJECTED
```

## Evidence

* CLAIM_01_claims_list.png
* CLAIM_02_claim_detail.png

---

# 3. Faculty Claim Review

## Description

Faculty members can review submitted claims together with associated attendance evidence.

During review, faculty can inspect:

* Attendance Record
* BLE Evidence
* GPS Evidence
* Student Explanation
* Previous Attendance Status

## Evidence

* CLAIM_02_claim_detail.png
* ATT_01_attendance_evidence.png

---

# 4. Approve Claim

## Endpoint

```http
POST /api/v1/claims/{claim_id}/approve
```

## Description

Approves a student claim and updates the attendance status accordingly.

## Authentication

Faculty JWT Required

## Request Example

```json
{
  "resolution_reason": "Attendance verified after evidence review."
}
```

## Success Response

```json
{
  "claim_id": 1,
  "status": "APPROVED"
}
```

## Evidence

* approve_claim_api.png
* CLAIM_03_approved_claim_detail.png

---

# 5. Reject Claim

## Endpoint

```http
POST /api/v1/claims/{claim_id}/reject
```

## Description

Rejects a submitted attendance claim.

## Authentication

Faculty JWT Required

## Request Example

```json
{
  "resolution_reason": "Evidence insufficient to overturn attendance decision."
}
```

## Success Response

```json
{
  "claim_id": 1,
  "status": "REJECTED"
}
```

## Evidence

* CLAIM_02_claim_detail.png

---

# Claim Status Lifecycle

```text
PENDING
   ↓
Faculty Review
   ↓
APPROVED
or
REJECTED
```

---

# Security Controls

## Claim Ownership Validation

Students may only access claims associated with their own attendance records.

Protection:

* Prevents unauthorized access.
* Prevents claim manipulation.

Status:

PASS

---

## Duplicate Claim Prevention

The system prevents multiple claims from being submitted for the same attendance record.

Protection:

* Eliminates duplicate requests.
* Simplifies faculty review.

Status:

PASS

---

## Faculty Authorization

Only authorized faculty members may approve or reject claims.

Protection:

* Role-based access control.
* Academic governance enforcement.

Status:

PASS

---

# Database Tables Used

## attendance_claims

Stores:

* Claim ID
* Attendance ID
* Student ID
* Claim Reason
* Status
* Resolution Reason
* Created Timestamp
* Resolved Timestamp

---

## attendance

Referenced to:

* Validate attendance ownership.
* Update attendance status after claim review.

---

## faculty_action_logs

Stores claim review actions performed by faculty members.

---

# Related Evidence

## Screenshots

* CLAIM_01_claims_list.png
* CLAIM_02_claim_detail.png
* CLAIM_03_approved_claim_detail.png

## API Evidence

* create_claim_api.png
* approve_claim_api.png

## Database Evidence

* claim_record.png
* claim_attendance_integrity.png

---

# Module Summary

The Claims API provides a secure and auditable attendance appeal mechanism.

Key Features:

* Student claim submission
* Faculty review workflow
* Approval and rejection processing
* Duplicate claim prevention
* Ownership validation
* Audit logging
* Attendance status correction

Security Status: PASS

Validation Status: PASS
