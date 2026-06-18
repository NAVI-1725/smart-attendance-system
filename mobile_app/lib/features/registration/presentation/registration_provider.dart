// mobile_app/lib/features/registration/presentation/registration_provider.dart

import 'package:flutter/foundation.dart';

import '../../faculty/models/registration_request.dart';
import '../data/registration_api_service.dart';

class RegistrationProvider extends ChangeNotifier {
  final RegistrationApiService _apiService;

  RegistrationProvider(this._apiService);

  bool isLoading = false;
  String? errorMessage;
  List<RegistrationRequest> requests = [];

  Future<void> loadRequests(int sessionId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final raw = await _apiService.getSessionRequests(
        sessionId: sessionId,
      );

      requests = raw
          .map(RegistrationRequest.fromJson)
          .toList();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveRequest(int requestId) async {
    try {
      await _apiService.approveRequest(requestId: requestId);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectRequest(int requestId) async {
    try {
      await _apiService.rejectRequest(requestId: requestId);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> approveAll(int sessionId) async {
    try {
      await _apiService.approveAll(sessionId: sessionId);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectAll(int sessionId) async {
    try {
      await _apiService.rejectAll(sessionId: sessionId);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}