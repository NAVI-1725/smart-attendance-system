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

  final TextEditingController
      _searchController =
      TextEditingController();

  String _searchQuery = '';

  @override
  void dispose() {
    _classroomIdController.dispose();
    _searchController.dispose();
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

          final filteredAttendance =
              provider.flaggedAttendance.where(
            (attendance) {
              if (_searchQuery
                  .trim()
                  .isEmpty) {
                return true;
              }

              final query =
                  _searchQuery
                      .toLowerCase()
                      .trim();

              return attendance
                      .attendanceId
                      .toString()
                      .contains(query) ||
                  attendance.studentName
                      .toLowerCase()
                      .contains(query) ||
                  attendance.courseName
                      .toLowerCase()
                      .contains(query);
            },
          ).toList();

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
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: TextField(
                  controller:
                      _searchController,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Search Attendance ID, Student Name, Course Name',
                    prefixIcon:
                        Icon(Icons.search),
                    border:
                        OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: provider.isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        itemCount:
                            filteredAttendance
                                .length,
                        itemBuilder:
                            (context, index) {
                          final attendance =
                              filteredAttendance[
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