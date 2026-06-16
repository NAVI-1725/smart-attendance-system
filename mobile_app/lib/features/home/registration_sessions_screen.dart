// mobile_app/lib/features/home/registration_sessions_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_bootstrap.dart';
import '../registration/data/registration_api_service.dart';
import '../registration/models/registration_session.dart';

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final _studentRegistrationApiProvider =
    Provider<RegistrationApiService>(
  (ref) => RegistrationApiService(
    AppBootstrap.apiClient,
  ),
);

final _openSessionsForStudentProvider =
    FutureProvider.autoDispose<List<RegistrationSession>>(
  (ref) async {
    final service = ref.read(
      _studentRegistrationApiProvider,
    );
    final raw = await service.getOpenSessions();
    return raw
        .map(RegistrationSession.fromJson)
        .toList();
  },
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class RegistrationSessionsScreen
    extends ConsumerStatefulWidget {
  const RegistrationSessionsScreen({
    super.key,
  });

  @override
  ConsumerState<RegistrationSessionsScreen> createState() =>
      _RegistrationSessionsScreenState();
}

class _RegistrationSessionsScreenState
    extends ConsumerState<RegistrationSessionsScreen> {
  final Set<int> _joiningSessionIds = {};

  Future<void> _joinSession(
    int sessionId,
  ) async {
    setState(
      () => _joiningSessionIds.add(sessionId),
    );

    try {
      final service = ref.read(
        _studentRegistrationApiProvider,
      );
      await service.joinSession(
        sessionId: sessionId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Successfully enrolled in course',
          ),
        ),
      );

      ref.invalidate(
        _openSessionsForStudentProvider,
      );
    } catch (e) {
      print(
        'JOIN SESSION ERROR: $e',
      );

      if (!mounted) return;

      String message =
          'Unable to join course';

      final errorText =
          e.toString().toLowerCase();

      if (errorText.contains('409')) {
        message =
            'You are already enrolled in this course';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } finally {
      if (mounted) {
        setState(
          () => _joiningSessionIds
              .remove(sessionId),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final openSessionsAsync = ref.watch(
      _openSessionsForStudentProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Course Registration',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(
            _openSessionsForStudentProvider,
          );
        },
        child: openSessionsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding:
                  const EdgeInsets.all(16),
              child: Text(
                'Error loading sessions: $err',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (sessions) {
            if (sessions.isEmpty) {
              return const Center(
                child: Text(
                  'No open registration sessions available',
                ),
              );
            }

            return ListView.builder(
              padding:
                  const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session =
                    sessions[index];
                final isJoining =
                    _joiningSessionIds
                        .contains(session.id);

                return Card(
                  margin:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      16,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          session.courseCode,
                          style: Theme.of(
                            context,
                          )
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          session.courseName,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        SizedBox(
                          width:
                              double.infinity,
                          child:
                              ElevatedButton(
                            onPressed:
                                isJoining
                                    ? null
                                    : () =>
                                        _joinSession(
                                          session
                                              .id,
                                        ),
                            child: isJoining
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                    ),
                                  )
                                : const Text(
                                    'Join Course',
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}