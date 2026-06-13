// mobile_app/lib/features/profile/presentation/profile_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/profile_api_service.dart';
import 'profile_state.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileApiService _apiService;

  ProfileNotifier(this._apiService)
      : super(ProfileState.initial());

  Future<void> loadProfile() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final profile =
          await _apiService.getProfile();

      state = state.copyWith(
        isLoading: false,
        profile: profile,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to load profile',
      );
    }
  }
}