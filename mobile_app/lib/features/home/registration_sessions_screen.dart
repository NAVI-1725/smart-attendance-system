// mobile_app/lib/features/home/registration_sessions_screen.dart

import 'package:dio/dio.dart';
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
  const RegistrationSessionsScreen({super.key});

  @override
  ConsumerState<RegistrationSessionsScreen> createState() =>
      _RegistrationSessionsScreenState();
}

class _RegistrationSessionsScreenState
    extends ConsumerState<RegistrationSessionsScreen> {
  final Set<int> _joiningSessionIds = {};

  Future<void> _joinSession(int sessionId) async {
    setState(
      () => _joiningSessionIds.add(sessionId),
    );

    try {
      final service = ref.read(
        _studentRegistrationApiProvider,
      );
      await service.joinSession(sessionId: sessionId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registration request submitted. Awaiting faculty approval.',
          ),
        ),
      );

      ref.invalidate(_openSessionsForStudentProvider);
    } on DioException catch (e) {
      if (!mounted) return;

      final serverDetail = e.response?.data is Map
          ? (e.response!.data as Map)['detail'] as String?
          : null;

      final String message;

      if (e.response?.statusCode == 409) {
        if (serverDetail != null &&
            serverDetail.toLowerCase().contains('already enrolled')) {
          message = 'You are already enrolled in this course';
        } else if (serverDetail != null &&
            serverDetail.toLowerCase().contains('already submitted')) {
          message =
              'You have already submitted a request for this course. Awaiting faculty approval.';
        } else if (serverDetail != null &&
            serverDetail.toLowerCase().contains('rejected')) {
          message =
              'Your registration request was rejected by the faculty.';
        } else if (serverDetail != null &&
            serverDetail.toLowerCase().contains('approved')) {
          message = 'Your registration request was already approved.';
        } else {
          message = serverDetail ?? 'Unable to submit registration request';
        }
      } else if (e.response?.statusCode == 400) {
        message = serverDetail ?? 'Registration session is no longer active';
      } else {
        message = serverDetail ?? 'Unable to submit registration request';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to submit registration request'),
        ),
      );
    } finally {
      if (mounted) {
        setState(
          () => _joiningSessionIds.remove(sessionId),
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
        title: const Text('Course Registration'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_openSessionsForStudentProvider);
        },
        child: openSessionsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
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
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                final isJoining = _joiningSessionIds
                    .contains(session.id);

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.courseCode,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(session.courseName),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isJoining
                                ? null
                                : () => _joinSession(
                                      session.id,
                                    ),
                            child: isJoining
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Request to Join',
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