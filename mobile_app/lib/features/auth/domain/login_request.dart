// mobile_app\lib\features\auth\domain\login_request.dart
class LoginRequest {
  final String email;
  final String password;
  final String deviceUuid;

  LoginRequest({
    required this.email,
    required this.password,
    required this.deviceUuid,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'device_uuid': deviceUuid, // REQUIRED by backend
    };
  }
}
