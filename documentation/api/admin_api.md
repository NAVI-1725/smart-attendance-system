# Admin API Documentation

## Module Overview

The Admin API provides governance and management functions for users, courses, classrooms, enrollments, BLE beacons, and devices.

---

# 1. Create Faculty

## Endpoint

```http
POST /api/v1/admin/faculty
```

## Description

Creates a new faculty account.

## Evidence

* create_faculty_api.png

---

# 2. Create Student

## Endpoint

```http
POST /api/v1/admin/students
```

## Description

Creates a new student account.

## Evidence

* create_student_api.png

---

# 3. Create Course

## Endpoint

```http
POST /api/v1/admin/courses
```

## Description

Creates a new course.

## Evidence

* create_course_api.png

---

# 4. Assign Faculty

## Endpoint

```http
POST /api/v1/admin/faculty-courses
```

## Description

Assigns a faculty member to a course.

## Evidence

* assign_faculty_api.png

---

# 5. Student Enrollment

## Endpoint

```http
POST /api/v1/admin/enrollments
```

## Description

Enrolls a student into a course.

## Evidence

* enrollment_api.png

---

# 6. Classroom Management

## Description

Allows administrators to create and manage classrooms.

## Evidence

* create_classroom_api.png

---

# 7. Beacon Assignment

## Description

Assigns trusted BLE beacons to classrooms.

## Evidence

* assign_beacon_api.png

---

# 8. Device Management

## Description

Administrators may unbind student devices when required.

## Evidence

* device_unbind_api.png

---

# Managed Resources

* Users
* Courses
* Faculty Assignments
* Enrollments
* Classrooms
* BLE Beacons
* Devices

---

# Database Tables Used

* users
* courses
* faculty_courses
* enrollments
* classrooms
* trusted_ble_beacons
* devices

---

# Security Features

* Administrative Role Enforcement
* Device Governance
* Academic Ownership Controls
* Enrollment Integrity Validation
