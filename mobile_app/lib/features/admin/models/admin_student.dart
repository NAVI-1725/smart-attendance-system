// mobile_app/lib/features/admin/models/admin_student.dart

class AdminStudent {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final bool isActive;

  const AdminStudent({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isActive,
  });

  factory AdminStudent.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminStudent(
      id: json['id'] as int,
      fullName:
          json['full_name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      isActive:
          json['is_active'] as bool,
    );
  }
}