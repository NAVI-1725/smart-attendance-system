// mobile_app/lib/features/attendance/presentation/attendance_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../claims/presentation/claim_submission_dialog.dart';
import 'history_provider.dart';

class AttendanceHistoryScreen
    extends ConsumerStatefulWidget {
  const AttendanceHistoryScreen({
    super.key,
  });

  @override
  ConsumerState<AttendanceHistoryScreen>
      createState() =>
          _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState
    extends ConsumerState<
        AttendanceHistoryScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(
            historyNotifierProvider.notifier,
          )
          .loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      historyNotifierProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance History',
        ),
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (state.error != null) {
            return Center(
              child: Text(
                state.error!,
              ),
            );
          }

          if (state.records.isEmpty) {
            return const Center(
              child: Text(
                'No attendance records found',
              ),
            );
          }

          return ListView.builder(
            itemCount: state.records.length,
            itemBuilder: (
              context,
              index,
            ) {
              final record =
                  state.records[index];

              return Card(
                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        '${record.courseCode} - ${record.courseName}',
                        style:
                            Theme.of(context)
                                .textTheme
                                .titleMedium,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Status: ${record.status}',
                      ),
                      Text(
                        record.timestamp
                            .toLocal()
                            .toString(),
                      ),
                      if (((record.status
                                      .toUpperCase() ==
                                  'REJECTED') ||
                              (record.status
                                      .toUpperCase() ==
                                  'FLAGGED')) &&
                          !record.hasClaim) ...[
                        const SizedBox(
                          height: 12,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final submitted =
                                await showDialog<bool>(
                              context:
                                  context,
                              builder:
                                  (
                                    context,
                                  ) =>
                                      ClaimSubmissionDialog(
                                        attendanceId:
                                            record
                                                .attendanceId,
                                      ),
                            );

                            if (submitted ==
                                true) {
                              ref
                                  .read(
                                    historyNotifierProvider
                                        .notifier,
                                  )
                                  .loadHistory();
                            }
                          },
                          child: const Text(
                            'Submit Claim',
                          ),
                        ),
                      ],
                      if (record.hasClaim) ...[
                        const SizedBox(
                          height: 12,
                        ),
                        const Chip(
                          label: Text(
                            'Claim Submitted',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}