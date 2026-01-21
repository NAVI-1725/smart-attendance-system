import '../services/api_client.dart';
import '../services/local_storage_service.dart';

class AppBootstrap {
  static late final ApiClient apiClient;
  static late final LocalStorageService localStorageService;

  static Future<void> init() async {
    // Initialize local storage first
    localStorageService = LocalStorageService();
    await localStorageService.init();

    // Initialize API client
    apiClient = ApiClient();
  }
}
