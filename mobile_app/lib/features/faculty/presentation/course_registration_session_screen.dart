// mobile_app/lib/features/faculty/presentation/course_registration_session_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_bootstrap.dart';
import '../../registration/data/registration_api_service.dart';
import '../../registration/models/registration_session.dart';
import 'faculty_provider.dart';
import 'registration_requests_screen.dart';

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final _registrationApiServiceProvider = Provider<RegistrationApiService>(
  (ref) => RegistrationApiService(AppBootstrap.apiClient),
);

final _openRegistrationSessionsProvider =
    FutureProvider.autoDispose<List<RegistrationSession>>((ref) async {
      final service = ref.read(_registrationApiServiceProvider);
      final raw = await service.getOpenSessions();
      return raw.map(RegistrationSession.fromJson).toList();
    });

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class CourseRegistrationSessionScreen extends ConsumerStatefulWidget {
  const CourseRegistrationSessionScreen({super.key});

  @override
  ConsumerState<CourseRegistrationSessionScreen> createState() =>
      _CourseRegistrationSessionScreenState();
}

class _CourseRegistrationSessionScreenState
    extends ConsumerState<CourseRegistrationSessionScreen> {
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(facultyProvider).loadCourses();
    });
  }

  Future<void> _startSession(int courseId) async {
    setState(() => _isActionLoading = true);

    try {
      final service = ref.read(_registrationApiServiceProvider);
      await service.startSession(courseId: courseId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration session started')),
      );

      ref.invalidate(_openRegistrationSessionsProvider);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _isActionLoading = false);
      }
    }
  }

  Future<void> _closeSession(int sessionId) async {
    setState(() => _isActionLoading = true);

    try {
      final service = ref.read(_registrationApiServiceProvider);
      await service.closeSession(sessionId: sessionId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration session closed')),
      );

      ref.invalidate(_openRegistrationSessionsProvider);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _isActionLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final facultyState = ref.watch(facultyProvider);
    final openSessionsAsync = ref.watch(_openRegistrationSessionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Registration Sessions')),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(facultyProvider).loadCourses();
          ref.invalidate(_openRegistrationSessionsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ----------------------------------------------------------
            // Section: Assigned Courses — Start Registration
            // ----------------------------------------------------------
            Text('My Courses', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),

            if (facultyState.isLoading && facultyState.courses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (facultyState.courses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No courses assigned'),
              )
            else
              ...facultyState.courses.map(
                (course) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.courseCode,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(course.courseName),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        if (openSessionsAsync.hasValue)
                          (() {
                            final sessions = openSessionsAsync.value!;

                            final hasActiveSession = sessions.any(
                              (s) => s.courseId == course.courseId,
                            );

                            if (hasActiveSession) {
                              return const Chip(label: Text('Session Active'));
                            }

                            return ElevatedButton(
                              onPressed: _isActionLoading
                                  ? null
                                  : () => _startSession(course.courseId),
                              child: const Text('Start Registration'),
                            );
                          })()
                        else
                          ElevatedButton(
                            onPressed: _isActionLoading
                                ? null
                                : () => _startSession(course.courseId),
                            child: const Text('Start Registration'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // ----------------------------------------------------------
            // Section: Active Registration Sessions
            // ----------------------------------------------------------
            Text(
              'Active Sessions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),

            openSessionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error loading sessions: $err'),
              data: (sessions) {
                if (sessions.isEmpty) {
                  return const Text('No active registration sessions');
                }

                return Column(
                  children: sessions.map((session) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.courseName,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              session.courseCode,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: session.isActive
                                    ? Colors.green.shade100
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                session.isActive ? 'Active' : 'Closed',
                                style: TextStyle(
                                  color: session.isActive
                                      ? Colors.green.shade800
                                      : Colors.grey.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              RegistrationRequestsScreen(
                                                sessionId: session.id,
                                                courseName: session.courseName,
                                                courseCode: session.courseCode,
                                              ),
                                        ),
                                      );
                                    },
                                    child: const Text('View Requests'),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: _isActionLoading
                                        ? null
                                        : () => _closeSession(session.id),
                                    child: const Text('Close Registration'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
