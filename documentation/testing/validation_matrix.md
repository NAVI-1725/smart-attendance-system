# Validation Matrix

| ID       | Feature                    | Expected Result                              | Actual Result                             | Status | Evidence                                 |
| -------- | -------------------------- | -------------------------------------------- | ----------------------------------------- | ------ | ---------------------------------------- |
| AUTH-01  | Student Login              | Student authenticates successfully           | Login completed successfully              | PASS   | STU_01_login_screen.png                  |
| AUTH-02  | Faculty Login              | Faculty authenticates successfully           | Login completed successfully              | PASS   | FAC_00_login.png                         |
| AUTH-03  | Device Binding             | Device registered and linked to user account | Device registered successfully            | PASS   | STU_06_student_profile.png               |
| AUTH-04  | Device Rebinding           | User can register a new device after unbind  | New device registration successful        | PASS   | SEC_03_device_reset_success.png          |
| ATT-01   | Session Discovery          | Student can view active attendance sessions  | Active sessions displayed successfully    | PASS   | STU_02_active_session_available.png      |
| ATT-02   | Attendance Submission      | Attendance submitted successfully            | Attendance marked and confirmed           | PASS   | STU_03_attendance_confirmed.png          |
| ATT-03   | BLE Validation             | BLE evidence validated successfully          | BLE evidence recorded and verified        | PASS   | ATT_01_attendance_evidence.png           |
| ATT-04   | GPS Validation             | GPS evidence validated successfully          | GPS evidence recorded and verified        | PASS   | ATT_01_attendance_evidence.png           |
| ATT-05   | Attendance History         | Student can view attendance history          | Attendance history displayed successfully | PASS   | STU_04_attendance_history.png            |
| FAC-01   | Start Session              | Faculty can create attendance session        | Session created successfully              | PASS   | FAC_01_faculty_sessions.png              |
| FAC-02   | View Flagged Attendance    | Faculty can review flagged attendance        | Flagged attendance displayed              | PASS   | FAC_02_flagged_attendance_list.png       |
| FAC-03   | Review Attendance          | Faculty can inspect attendance details       | Attendance details displayed              | PASS   | FAC_03_attendance_detail_flagged.png     |
| FAC-04   | Confirm Attendance         | Faculty can confirm attendance record        | Attendance confirmed successfully         | PASS   | FAC_04_attendance_confirmed.png          |
| FAC-05   | Reject Attendance          | Faculty can reject attendance record         | Attendance rejection successful           | PASS   | FAC_03_attendance_detail_flagged.png     |
| FAC-06   | Export Attendance          | Faculty can export attendance data           | CSV exported successfully                 | PASS   | FAC_13_export_attendance_csv.png         |
| REG-01   | Registration Session       | Faculty can start registration session       | Registration session started              | PASS   | FAC_08_registration_session_active.png   |
| REG-02   | Registration Request       | Student can submit registration request      | Request submitted successfully            | PASS   | STU_08_course_registration_request.png   |
| REG-03   | Registration Approval      | Faculty can approve registration request     | Request approved successfully             | PASS   | FAC_10_registration_request_approved.png |
| CLAIM-01 | Submit Claim               | Student can submit attendance claim          | Claim submitted successfully              | PASS   | STU_05_my_claims.png                     |
| CLAIM-02 | View Claim                 | Claim details accessible                     | Claim details displayed successfully      | PASS   | CLAIM_02_claim_detail.png                |
| CLAIM-03 | Approve Claim              | Faculty can approve claim                    | Claim approved successfully               | PASS   | CLAIM_03_approved_claim_detail.png       |
| ADM-01   | Create Faculty             | Faculty account created successfully         | Faculty created successfully              | PASS   | ADM_01_create_faculty_01.png             |
| ADM-02   | Create Student             | Student account created successfully         | Student created successfully              | PASS   | ADM_02_create_student_01.png             |
| ADM-03   | Create Course              | Course created successfully                  | Course created successfully               | PASS   | ADM_03_create_course_01.png              |
| ADM-04   | Assign Faculty             | Faculty assigned to course                   | Assignment completed successfully         | PASS   | ADM_04_assign_faculty_01.png             |
| ADM-05   | Enroll Student             | Student enrolled successfully                | Enrollment completed successfully         | PASS   | ADM_05_enroll_student_01.png             |
| ADM-06   | Create Classroom           | Classroom created successfully               | Classroom created successfully            | PASS   | ADM_06_create_classroom_01.png           |
| ADM-07   | Assign Beacon              | Beacon assigned to classroom                 | Beacon assignment completed               | PASS   | ADM_07_assign_beacon_01.png              |
| ADM-08   | Device Unbind              | Device removed from account                  | Device unbound successfully               | PASS   | ADM_08_unbind_device_01.png              |
| SEC-01   | Invalid BLE Evidence       | Invalid BLE submission rejected              | Attendance blocked successfully           | PASS   | SEC_04_invalid_ble_evidence.png          |
| SEC-02   | Replay Protection          | Duplicate nonce prevented                    | Replay attack prevented                   | PASS   | ble_nonce_cache.png                      |
| SEC-03   | Claim Ownership Protection | Users cannot access others' claims           | Access restricted successfully            | PASS   | CLAIM_02_claim_detail.png                |

## Summary

Total Tests Executed: 33

Passed: 33

Failed: 0

Pass Rate: 100%
