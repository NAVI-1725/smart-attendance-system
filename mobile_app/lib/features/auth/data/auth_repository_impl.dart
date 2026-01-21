import '../domain/auth_repository.dart';
import '../domain/login_request.dart';
import '../domain/login_response.dart';
import 'auth_api_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _apiService;

  AuthRepositoryImpl(this._apiService);

  @override
  Future<LoginResponse> login(LoginRequest request) {
    return _apiService.login(request);
  }
}
