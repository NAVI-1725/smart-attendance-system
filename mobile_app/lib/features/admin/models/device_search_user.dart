// mobile_app/lib/features/admin/models/device_search_user.dart

class DeviceSearchUser {
  final int id;
  final String fullName;
  final String email;
  final String role;

  DeviceSearchUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory DeviceSearchUser.fromJson(
    Map<String, dynamic> json,
  ) {
    return DeviceSearchUser(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }
}