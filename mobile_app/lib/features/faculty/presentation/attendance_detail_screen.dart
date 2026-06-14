// mobile_app/lib/features/faculty/presentation/attendance_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/faculty_provider.dart';
import 'attendance_evidence_screen.dart';

class AttendanceDetailScreen
    extends ConsumerStatefulWidget {
  final int attendanceId;

  const AttendanceDetailScreen({
    super.key,
    required this.attendanceId,
  });

  @override
  ConsumerState<AttendanceDetailScreen>
      createState() =>
          _AttendanceDetailScreenState();
}

class _AttendanceDetailScreenState
    extends ConsumerState<AttendanceDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        ref
            .read(facultyProvider)
            .loadAttendanceDetail(
              widget.attendanceId,
            );
      },
    );
  }

  Future<void> _confirmAttendance() async {
    try {
      await ref
          .read(facultyProvider)
          .resolveAttendance(
            attendanceId: widget.attendanceId,
            status: 'CONFIRMED',
            reason:
                'Verified BLE and GPS evidence',
          );

      if (!mounted) return;

      await ref
          .read(facultyProvider)
          .loadAttendanceDetail(
            widget.attendanceId,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Attendance confirmed',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final errorMessage =
          e.toString();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage.contains(
                    'Attendance already reviewed')
                ? 'Attendance already reviewed'
                : errorMessage,
          ),
        ),
      );
    }
  }

  Future<void> _rejectAttendance() async {
    final controller =
        TextEditingController();

    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Reject Attendance',
          ),
          content: TextField(
            controller: controller,
            decoration:
                const InputDecoration(
              labelText: 'Enter reason',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final value =
                    controller.text.trim();

                if (value.isEmpty) {
                  return;
                }

                Navigator.pop(
                  context,
                  value,
                );
              },
              child: const Text(
                'Reject',
              ),
            ),
          ],
        );
      },
    );

    if (reason == null ||
        reason.trim().isEmpty) {
      return;
    }

    try {
      await ref
          .read(facultyProvider)
          .resolveAttendance(
            attendanceId:
                widget.attendanceId,
            status: 'REJECTED',
            reason: reason,
          );

      if (!mounted) return;

      await ref
          .read(facultyProvider)
          .loadAttendanceDetail(
            widget.attendanceId,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Attendance rejected',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final errorMessage =
          e.toString();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage.contains(
                    'Attendance already reviewed')
                ? 'Attendance already reviewed'
                : errorMessage,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance Detail',
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

          if (provider.isLoading &&
              provider.attendanceDetail ==
                  null) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final detail =
              provider.attendanceDetail;

          if (detail == null) {
            return const Center(
              child: Text(
                'Attendance not found',
              ),
            );
          }

          return SingleChildScrollView(
            padding:
                const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Card(
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
                          'Attendance ID: ${detail.attendanceId}',
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Student ID: ${detail.studentId}',
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Student Name: ${detail.studentName}',
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Session ID: ${detail.sessionId}',
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Course Name: ${detail.courseName}',
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Status: ${detail.status}',
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Reviewed By: ${detail.reviewedBy ?? 'N/A'}',
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Reviewed At: ${detail.reviewedAt?.toString() ?? 'N/A'}',
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Resolution Reason: ${detail.resolutionReason ?? 'N/A'}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AttendanceEvidenceScreen(
                            attendanceId:
                                detail
                                    .attendanceId,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'View Evidence',
                    ),
                  ),
                ),
                if (detail.status == 'FLAGGED') ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          provider.isLoading
                              ? null
                              : _confirmAttendance,
                      child: const Text(
                        'Confirm',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          provider.isLoading
                              ? null
                              : _rejectAttendance,
                      child: const Text(
                        'Reject',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}