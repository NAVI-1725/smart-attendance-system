// mobile_app/lib/features/profile/presentation/profile_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_bootstrap.dart';
import '../data/profile_api_service.dart';
import 'profile_notifier.dart';
import 'profile_state.dart';

final profileApiServiceProvider =
    Provider<ProfileApiService>(
  (ref) => ProfileApiService(
    AppBootstrap.apiClient,
  ),
);

final profileNotifierProvider =
    StateNotifierProvider<
      ProfileNotifier,
      ProfileState
    >(
  (ref) => ProfileNotifier(
    ref.read(
      profileApiServiceProvider,
    ),
  ),
);