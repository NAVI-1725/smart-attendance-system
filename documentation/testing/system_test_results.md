# TEST-G1

## Governance Chain Validation

### Objective

Validate the complete end-to-end workflow of the Smart Hybrid Attendance System from administrative setup through attendance submission, claim processing, and device security management.

---

## Test Flow

### Phase 1 — Administrative Setup

1. Admin created Faculty account.
2. Admin created Student account.
3. Admin created Course.
4. Admin assigned Faculty to Course.
5. Admin enrolled Student into Course.
6. Admin created Classroom.
7. Admin assigned BLE Beacon to Classroom.

Result: PASS

Evidence:

* ADM_01_create_faculty_01.png
* ADM_02_create_student_01.png
* ADM_03_create_course_01.png
* ADM_04_assign_faculty_01.png
* ADM_05_enroll_student_01.png
* ADM_06_create_classroom_01.png
* ADM_07_assign_beacon_01.png

---

### Phase 2 — Faculty Session Management

1. Faculty authenticated successfully.
2. Faculty started attendance session.
3. Session became available to enrolled students.

Result: PASS

Evidence:

* FAC_01_faculty_sessions.png

---

### Phase 3 — Student Attendance Workflow

1. Student authenticated successfully.
2. Active session discovered.
3. BLE evidence collected.
4. GPS evidence collected.
5. Attendance submitted successfully.
6. Attendance recorded in database.

Result: PASS

Evidence:

* STU_01_login_screen.png
* STU_02_active_session_available.png
* STU_03_attendance_confirmed.png
* ATT_01_attendance_evidence.png

---

### Phase 4 — Faculty Review Workflow

1. Faculty reviewed flagged attendance.
2. Attendance details inspected.
3. Evidence verified.
4. Attendance confirmed successfully.

Result: PASS

Evidence:

* FAC_02_flagged_attendance_list.png
* FAC_03_attendance_detail_flagged.png
* FAC_04_attendance_confirmed.png

---

### Phase 5 — Claims Workflow

1. Student submitted attendance claim.
2. Faculty reviewed claim.
3. Faculty approved claim.
4. Resolution recorded successfully.

Result: PASS

Evidence:

* CLAIM_01_claims_list.png
* CLAIM_02_claim_detail.png
* CLAIM_03_approved_claim_detail.png

---

### Phase 6 — Device Security Workflow

1. Device binding verified.
2. Device reset initiated.
3. Device unbound successfully.
4. New device registration allowed.

Result: PASS

Evidence:

* SEC_01_device_reset_confirmation.png
* SEC_02_device_registered.png
* SEC_03_device_reset_success.png

---

## Overall Result

TEST-G1 Status: PASS

System Modules Validated:

* Authentication
* Device Binding
* Course Management
* Enrollment Management
* BLE Validation
* GPS Validation
* Attendance Processing
* Faculty Review
* Claims Management
* Registration Workflow
* Security Controls

Final Result: PASS
