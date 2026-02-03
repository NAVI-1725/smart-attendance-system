// mobile_app/lib/features/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/presentation/auth_provider.dart';
import '../attendance/presentation/session_provider.dart';
import '../attendance/presentation/attendance_provider.dart';
import '../attendance/domain/attendance_status.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionNotifierProvider);
    final attendanceState = ref.watch(attendanceNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Session Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 5️⃣ Active Session Check (READ-ONLY)
            if (sessionState.isLoading)
              const CircularProgressIndicator()
            else if (sessionState.hasActiveSession)
              Text(
                'Active session found\nSession ID: ${sessionState.activeSession!.sessionId}',
              )
            else
              const Text('No active session'),

            const SizedBox(height: 24),

            // Enable / disable attendance button strictly based on active session
            if (sessionState.hasActiveSession) ...[
              ElevatedButton(
                onPressed: attendanceState.isLoading
                    ? null
                    : () {
                        ref
                            .read(attendanceNotifierProvider.notifier)
                            .submitAttendance(
                              sessionState.activeSession!.sessionId,
                            );
                      },
                child: attendanceState.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Mark Attendance'),
              ),
            ],

            const SizedBox(height: 16),

            // 6️⃣ Attendance Result UI (READ-ONLY)
            if (attendanceState.attempt != null)
              Text(
                attendanceState.attempt!.status == AttendanceStatus.confirmed
                    ? 'Confirmed'
                    : 'Flagged – Pending review',
                style: TextStyle(
                  color:
                      attendanceState.attempt!.status ==
                          AttendanceStatus.confirmed
                      ? Colors.green
                      : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),

            if (attendanceState.error != null)
              Text(
                attendanceState.error!,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
