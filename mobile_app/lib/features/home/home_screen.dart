// mobile_app/lib/features/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/ble/ble_service_provider.dart';
import '../auth/presentation/auth_provider.dart';
import '../attendance/presentation/session_provider.dart';
import '../attendance/presentation/attendance_provider.dart';
import '../attendance/domain/attendance_status.dart';

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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () async {
                try {
                  print('BUTTON CLICKED');

                  final bleService =
                      ref.read(bleServiceProvider);

                  final results =
                      await bleService.scan(
                    duration: const Duration(seconds: 15),
                  );

                  print(
                    'SCAN FINISHED',
                  );

                  print(
                    'RESULT COUNT: ${results.length}',
                  );

                  for (final sample in results) {
                    print(
                      'Beacon: ${sample.beaconId} | '
                      'RSSI: ${sample.rssi} | '
                      'Nonce: ${sample.nonce} | '
                      'Signature: ${sample.signature} | '
                      'LastSeen: ${sample.lastSeenEpochMs}',
                    );
                  }
                } catch (e) {
                  print('BLE ERROR: $e');
                }
              },
              child: const Text('TEST BLE PART B'),
            ),

            const SizedBox(height: 12),

            if (sessionState.isLoading)
              const Text('Loading sessions...')
            else if (!sessionState.hasSessions)
              const Text('No active sessions available')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: sessionState.activeSessions.length,
                  itemBuilder: (context, index) {
                    final session =
                        sessionState.activeSessions[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.courseCode,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(session.courseName),
                            const SizedBox(height: 12),

                            Text(
                              'Faculty: ${session.facultyName}',
                            ),
                            Text(
                              'Classroom: ${session.classroomName}',
                            ),
                            Text(
                              'Expires: ${session.expiresAt}',
                            ),

                            const SizedBox(height: 12),

                            ElevatedButton(
                              onPressed: attendanceState.isLoading
                                  ? null
                                  : () {
                                      ref
                                          .read(
                                            attendanceNotifierProvider
                                                .notifier,
                                          )
                                          .submitAttendance(
                                            session.sessionId.toString(),
                                          );
                                    },
                              child: attendanceState.isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
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
                        AttendanceStatus.confirmed
                    ? 'Confirmed'
                    : 'Flagged – Pending review',
                style: TextStyle(
                  color: attendanceState.attempt!.status ==
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