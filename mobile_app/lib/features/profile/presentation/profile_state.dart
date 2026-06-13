// mobile_app\lib\features\profile\presentation\profile_state.dart
// mobile_app/lib/features/profile/presentation/profile_state.dart

import '../domain/profile_model.dart';

class ProfileState {
  final bool isLoading;
  final ProfileModel? profile;
  final String? error;

  const ProfileState({
    this.isLoading = false,
    this.profile,
    this.error,
  });

  factory ProfileState.initial() {
    return const ProfileState(
      isLoading: false,
    );
  }

  ProfileState copyWith({
    bool? isLoading,
    ProfileModel? profile,
    String? error,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      error: error,
    );
  }
}