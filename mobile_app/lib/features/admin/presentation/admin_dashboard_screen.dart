// mobile_app/lib/features/admin/presentation/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_provider.dart';
import '../../profile/presentation/profile_screen.dart';
import 'admin_provider.dart';
import 'beacons/beacon_management_screen.dart';
import 'classrooms/classroom_management_screen.dart';
import 'courses/course_management_screen.dart';
import 'device_management_screen.dart';
import 'enrollments/enrollment_management_screen.dart';
import 'faculty/faculty_management_screen.dart';
import 'faculty_course/faculty_course_management_screen.dart';
import 'students/student_management_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider).loadSystemSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
        ),
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final provider = ref.watch(adminProvider);

          if (provider.isLoading && provider.systemSummary == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final summary = provider.systemSummary;

          if (summary == null) {
            return const Center(child: Text('No dashboard data available'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadSystemSummary();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _DashboardCard(
                  title: 'Students',
                  value: summary.students.toString(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StudentManagementScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _DashboardCard(
                  title: 'Faculty',
                  value: summary.faculty.toString(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FacultyManagementScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _DashboardCard(
                  title: 'Faculty Assignments',
                  value: '',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FacultyCourseManagementScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _DashboardCard(
                  title: 'Courses',
                  value: summary.courses.toString(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CourseManagementScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _DashboardCard(
                  title: 'Enrollments',
                  value: summary.enrollments.toString(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EnrollmentManagementScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _DashboardCard(
                  title: 'Classrooms',
                  value: summary.classrooms.toString(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ClassroomManagementScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _DashboardCard(
                  title: 'Beacons',
                  value: summary.beacons.toString(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BeaconManagementScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _DashboardCard(
                  title: 'Device Management',
                  value: summary.devicesBound.toString(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DeviceManagementScreen(),
                      ),
                    );
                  },
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

  const _DashboardCard({required this.title, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
        ),
      ),
    );
  }
}