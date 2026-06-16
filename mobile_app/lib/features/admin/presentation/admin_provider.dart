// mobile_app/lib/features/admin/presentation/admin_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_bootstrap.dart';

import '../data/admin_api_service.dart';
import '../data/admin_repository.dart';
import '../providers/admin_provider.dart'
    as admin_logic;

final adminRepositoryProvider =
    Provider<AdminRepository>(
  (ref) {
    return AdminRepository(
      AdminApiService(
        AppBootstrap.apiClient,
      ),
    );
  },
);

final adminProvider =
    ChangeNotifierProvider<
        admin_logic.AdminProvider>(
  (ref) {
    return admin_logic.AdminProvider(
      ref.watch(
        adminRepositoryProvider,
      ),
    );
  },
);