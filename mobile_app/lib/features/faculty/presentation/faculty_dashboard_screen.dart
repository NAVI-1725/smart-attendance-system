// mobile_app/lib/features/faculty/presentation/faculty_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/faculty_provider.dart';
import 'faculty_courses_screen.dart';
import 'faculty_sessions_screen.dart';
import 'flagged_attendance_screen.dart';

class FacultyDashboardScreen
    extends ConsumerStatefulWidget {
  const FacultyDashboardScreen({
    super.key,
  });

  @override
  ConsumerState<FacultyDashboardScreen>
      createState() =>
          _FacultyDashboardScreenState();
}

class _FacultyDashboardScreenState
    extends ConsumerState<FacultyDashboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        ref
            .read(facultyProvider)
            .loadDashboard();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Faculty Dashboard',
        ),
      ),
      body: Consumer(
        builder: (
          context,
          ref,
          _,
        ) {
          final provider = ref.watch(
            facultyProvider,
          );

          if (provider.isLoading &&
              provider.dashboard == null) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final dashboard =
              provider.dashboard;

          if (dashboard == null) {
            return const Center(
              child: Text(
                'No dashboard data available',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadDashboard();
            },
            child: ListView(
              padding:
                  const EdgeInsets.all(16),
              children: [
                _DashboardCard(
                  title: 'My Courses',
                  value: 'View',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const FacultyCoursesScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _DashboardCard(
                  title: 'Active Sessions',
                  value: dashboard
                      .activeSessions
                      .toString(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const FacultySessionsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _DashboardCard(
                  title:
                      'Flagged Attendance',
                  value: dashboard
                      .flaggedAttendance
                      .toString(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const FlaggedAttendanceScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _DashboardCard(
                  title:
                      'Confirmed Today',
                  value: dashboard
                      .confirmedToday
                      .toString(),
                ),
                const SizedBox(height: 12),
                _DashboardCard(
                  title:
                      'Rejected Today',
                  value: dashboard
                      .rejectedToday
                      .toString(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _DashboardCard({
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(12),
        child: Padding(
          padding:
              const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    Theme.of(context)
                        .textTheme
                        .titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style:
                    Theme.of(context)
                        .textTheme
                        .headlineMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}