// mobile_app/lib/features/faculty/presentation/flagged_attendance_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'faculty_provider.dart';
import 'attendance_detail_screen.dart';

class FlaggedAttendanceScreen
    extends ConsumerStatefulWidget {
  const FlaggedAttendanceScreen({
    super.key,
  });

  @override
  ConsumerState<FlaggedAttendanceScreen>
      createState() =>
          _FlaggedAttendanceScreenState();
}

class _FlaggedAttendanceScreenState
    extends ConsumerState<FlaggedAttendanceScreen> {
  final TextEditingController
      _classroomIdController =
      TextEditingController();

  @override
  void dispose() {
    _classroomIdController.dispose();
    super.dispose();
  }

  Future<void> _loadAttendance() async {
    final classroomId = int.tryParse(
      _classroomIdController.text,
    );

    if (classroomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a valid classroom ID',
          ),
        ),
      );
      return;
    }

    await ref
        .read(facultyProvider)
        .loadFlaggedAttendance(
          classroomId: classroomId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flagged Attendance',
        ),
      ),
      body: Consumer(
        builder: (
          context,
          ref,
          _,
        ) {
          final provider =
              ref.watch(
                facultyProvider,
              );

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller:
                            _classroomIdController,
                        keyboardType:
                            TextInputType.number,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Classroom ID',
                          border:
                              OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed:
                          provider.isLoading
                              ? null
                              : _loadAttendance,
                      child: const Text(
                        'Load',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: provider.isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        itemCount: provider
                            .flaggedAttendance
                            .length,
                        itemBuilder:
                            (context, index) {
                          final attendance =
                              provider
                                      .flaggedAttendance[
                                  index];

                          return Card(
                            margin:
                                const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: ListTile(
                              title: Text(
                                'Attendance #${attendance.attendanceId}',
                              ),
                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    'Student Name: ${attendance.studentName}',
                                  ),
                                  Text(
                                    'Course Name: ${attendance.courseName}',
                                  ),
                                  Text(
                                    'Timestamp: ${attendance.timestamp}',
                                  ),
                                  Text(
                                    'Status: ${attendance.status}',
                                  ),
                                ],
                              ),
                              trailing: const Icon(
                                Icons
                                    .arrow_forward_ios,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AttendanceDetailScreen(
                                      attendanceId:
                                          attendance
                                              .attendanceId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}