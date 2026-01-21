// mobile_app\lib\core\config\app_config.dart
class AppConfig {
  AppConfig._();

  // Environment
  static const bool isDebug = true;

  // API
  static const String apiBaseUrl = 'http://10.0.2.2:8000/api/v1';

  // Network
  static const int connectTimeoutSeconds = 10;
  static const int receiveTimeoutSeconds = 10;
}
