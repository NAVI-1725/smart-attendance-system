// mobile_app/lib/features/profile/data/profile_api_service.dart

import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';
import '../domain/profile_model.dart';

class ProfileApiService {
  final ApiClient _apiClient;

  ProfileApiService(this._apiClient);

  Future<ProfileModel> getProfile() async {
    final Response response = await _apiClient.dio.get(
      '/auth/profile',
    );

    return ProfileModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}