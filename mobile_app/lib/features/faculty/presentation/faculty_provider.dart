// mobile_app/lib/features/faculty/presentation/faculty_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_bootstrap.dart';

import '../data/faculty_api_service.dart';
import '../data/faculty_repository.dart';
import '../providers/faculty_provider.dart'
    as faculty_logic;

final facultyRepositoryProvider =
    Provider<FacultyRepository>(
  (ref) {
    return FacultyRepository(
      FacultyApiService(
        AppBootstrap.apiClient,
      ),
    );
  },
);

final facultyProvider =
    ChangeNotifierProvider<
        faculty_logic.FacultyProvider>(
  (ref) {
    return faculty_logic.FacultyProvider(
      ref.watch(
        facultyRepositoryProvider,
      ),
    );
  },
);