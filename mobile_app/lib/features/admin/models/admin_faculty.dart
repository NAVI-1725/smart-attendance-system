// mobile_app/lib/features/admin/models/admin_faculty.dart

class AdminFaculty {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final bool isActive;

  const AdminFaculty({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isActive,
  });

  factory AdminFaculty.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminFaculty(
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