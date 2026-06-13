// mobile_app/lib/features/profile/domain/profile_model.dart

class ProfileModel {
  final int userId;
  final String role;
  final String fullName;
  final String email;
  final String? deviceId;

  const ProfileModel({
    required this.userId,
    required this.role,
    required this.fullName,
    required this.email,
    required this.deviceId,
  });

  factory ProfileModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProfileModel(
      userId: json['user_id'] as int,
      role: json['role'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      deviceId: json['device_id'] as String?,
    );
  }
}