// mobile_app\lib\core\services\api_client.dart
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../config/app_bootstrap.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout:
            Duration(seconds: AppConfig.connectTimeoutSeconds),
        receiveTimeout:
            Duration(seconds: AppConfig.receiveTimeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _addInterceptors();
  }

  void _addInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token =
              AppBootstrap.localStorageService.getAuthToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          return handler.next(error);
        },
      ),
    );
  }
}
