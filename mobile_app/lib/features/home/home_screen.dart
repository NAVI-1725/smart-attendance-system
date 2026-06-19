// mobile_app/lib/features/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../admin/presentation/device_management_screen.dart';
import '../auth/presentation/auth_provider.dart';
import '../attendance/presentation/attendance_history_screen.dart';
import '../attendance/presentation/session_provider.dart';
import '../attendance/presentation/attendance_provider.dart';
import '../attendance/domain/attendance_status.dart';
import '../claims/data/claims_api_service.dart';
import '../claims/domain/claim_status.dart';
import '../claims/presentation/my_claims_screen.dart';
import '../../core/services/api_client.dart';
import '../profile/presentation/profile_screen.dart';
import '../faculty/presentation/faculty_dashboard_screen.dart';
import 'registration_sessions_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends ConsumerState<HomeScreen> {
  final ClaimsApiService _claimsApiService =
      ClaimsApiService(
        ApiClient(),
      );

  int _claimNotificationCount = 0;

  Future<void> _loadClaimNotifications() async {
    try {
      final count =
          await _claimsApiService
              .getResolvedClaimsCount();

      if (!mounted) {
        return;
      }

      setState(() {
        _claimNotificationCount = count;
      });
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();

    ref.listenManual(
      attendanceNotifierProvider,
      (previous, next) {
        if (next.error != null &&
            next.error != previous?.error) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(next.error!),
            ),
          );
        }
      },
    );

    Future.microtask(() async {
      ref
          .read(
            sessionNotifierProvider.notifier,
          )
          .fetchActiveSessions();

      await _loadClaimNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(
      authNotifierProvider,
    );

    final role = authState.role;

    final sessionState = ref.watch(
      sessionNotifierProvider,
    );

    print(
      'ACTIVE SESSIONS: '
      '${sessionState.activeSessions.length}',
    );

    final attendanceState = ref.watch(
      attendanceNotifierProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              ref
                  .read(
                    attendanceNotifierProvider.notifier,
                  )
                  .reset();

              await ref
                  .read(
                    authNotifierProvider.notifier,
                  )
                  .logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: role == 'faculty'
            ? Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.person),
                      label: const Text(
                        'Profile',
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.dashboard,
                      ),
                      label: const Text(
                        'Faculty Dashboard',
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const FacultyDashboardScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : role == 'admin'
                ? Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.person),
                          label: const Text(
                            'Profile',
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ProfileScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.admin_panel_settings,
                          ),
                          label: const Text(
                            'Device Management',
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const DeviceManagementScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Admin Dashboard Coming Soon',
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Session Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.history),
                          label: const Text(
                            'Attendance History',
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const AttendanceHistoryScreen(),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.gavel),
                          label: Text(
                            _claimNotificationCount > 0
                                ? 'My Claims ($_claimNotificationCount)'
                                : 'My Claims',
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const MyClaimsScreen(),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.person),
                          label: const Text(
                            'Profile',
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ProfileScreen(),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.app_registration),
                          label: const Text(
                            'Course Registration',
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const RegistrationSessionsScreen(),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (sessionState.isLoading)
                        const Center(
                          child:
                              CircularProgressIndicator(),
                        )
                      else if (!sessionState.hasSessions)
                        const Text(
                          'No active sessions available',
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: sessionState
                                .activeSessions.length,
                            itemBuilder:
                                (context, index) {
                              final session =
                                  sessionState
                                          .activeSessions[
                                      index];

                              final attendanceAttempt =
                                  attendanceState.attempt;

                              final alreadySubmitted =
                                  sessionState
                                      .submittedSessionIds
                                      .contains(
                                        session
                                            .sessionId
                                            .toString(),
                                      );

                              return Card(
                                margin:
                                    const EdgeInsets.only(
                                  bottom: 16,
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
                                        style:
                                            const TextStyle(
                                          fontSize: 18,
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
                                      Text(
                                        'Faculty: ${session.facultyName}',
                                      ),
                                      Text(
                                        'Classroom: ${session.classroomName}',
                                      ),
                                      Text(
                                        'Expires: ${session.expiresAt}',
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      alreadySubmitted
                                          ? Chip(
                                              label: Text(
                                                attendanceAttempt?.status ==
                                                        AttendanceStatus.confirmed
                                                    ? 'Confirmed'
                                                    : 'Flagged',
                                              ),
                                            )
                                          : ElevatedButton(
                                              onPressed:
                                                  attendanceState
                                                          .isLoading
                                                      ? null
                                                      : () async {
                                                          await ref
                                                              .read(
                                                                attendanceNotifierProvider
                                                                    .notifier,
                                                              )
                                                              .submitAttendance(
                                                                session
                                                                    .sessionId
                                                                    .toString(),
                                                              );

                                                          final updatedAttendanceState =
                                                              ref.read(
                                                            attendanceNotifierProvider,
                                                          );

                                                          if (updatedAttendanceState
                                                                  .attempt !=
                                                              null) {
                                                            ref
                                                                .read(
                                                                  sessionNotifierProvider
                                                                      .notifier,
                                                                )
                                                                .markSessionSubmitted(
                                                                  session
                                                                      .sessionId
                                                                      .toString(),
                                                                );
                                                          }
                                                        },
                                              child: attendanceState
                                                      .isLoading
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
                                                      'Mark Attendance',
                                                    ),
                                            ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 16),

                      if (attendanceState.attempt != null)
                        Text(
                          attendanceState.attempt!.status ==
                                  AttendanceStatus
                                      .confirmed
                              ? 'Confirmed'
                              : 'Flagged – Pending review',
                          style: TextStyle(
                            color: attendanceState
                                        .attempt!
                                        .status ==
                                    AttendanceStatus
                                        .confirmed
                                ? Colors.green
                                : Colors.orange,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}