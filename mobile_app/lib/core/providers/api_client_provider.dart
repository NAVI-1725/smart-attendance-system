import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_bootstrap.dart';
import '../services/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return AppBootstrap.apiClient;
});
