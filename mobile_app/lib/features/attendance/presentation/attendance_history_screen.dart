// mobile_app/lib/features/attendance/presentation/attendance_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                child: ListTile(
                  title: Text(
                    '${record.courseCode} - ${record.courseName}',
                  ),
                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Text(
                        'Status: ${record.status}',
                      ),
                      Text(
                        record.timestamp
                            .toLocal()
                            .toString(),
                      ),
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