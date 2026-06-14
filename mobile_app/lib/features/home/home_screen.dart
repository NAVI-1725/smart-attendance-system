// mobile_app/lib/features/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../admin/presentation/device_management_screen.dart';
import '../auth/presentation/auth_provider.dart';
import '../attendance/presentation/attendance_history_screen.dart';
import '../attendance/presentation/session_provider.dart';
import '../attendance/presentation/attendance_provider.dart';
import '../attendance/domain/attendance_status.dart';
import '../profile/presentation/profile_screen.dart';
import '../faculty/presentation/faculty_dashboard_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends ConsumerState<HomeScreen> {
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

    Future.microtask(() {
      ref
          .read(
            sessionNotifierProvider.notifier,
          )
          .fetchActiveSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(
      authNotifierProvider,
    );

    final role = authState.role;

    final sessionState = ref.watch(sessionNotifierProvider);

    print(
      'ACTIVE SESSIONS: '
      '${sessionState.activeSessions.length}',
    );

    final attendanceState = ref.watch(attendanceNotifierProvider);

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
                                      ElevatedButton(
                                        onPressed:
                                            attendanceState
                                                    .isLoading
                                                ? null
                                                : () {
                                                    ref
                                                        .read(
                                                          attendanceNotifierProvider
                                                              .notifier,
                                                        )
                                                        .submitAttendance(
                                                          session
                                                              .sessionId
                                                              .toString(),
                                                        );
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