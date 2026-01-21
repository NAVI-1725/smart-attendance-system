import '../domain/login_request.dart';
import '../domain/login_response.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(LoginRequest request);
}
