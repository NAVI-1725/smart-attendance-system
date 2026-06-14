// mobile_app/lib/features/faculty/presentation/session_monitor_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/session_attendance.dart';
import 'attendance_detail_screen.dart';
import 'faculty_provider.dart';

class SessionMonitorScreen
    extends ConsumerStatefulWidget {
  final int sessionId;

  const SessionMonitorScreen({
    super.key,
    required this.sessionId,
  });

  @override
  ConsumerState<SessionMonitorScreen>
      createState() =>
          _SessionMonitorScreenState();
}

class _SessionMonitorScreenState
    extends ConsumerState<SessionMonitorScreen> {
  final TextEditingController
      _searchController =
      TextEditingController();

  String _searchQuery = '';

  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        ref
            .read(facultyProvider)
            .loadSessionAttendance(
              widget.sessionId,
            );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Session ${widget.sessionId} Monitoring',
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
              provider.sessionAttendance ==
                  null) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final attendance =
              provider.sessionAttendance;

          if (attendance == null) {
            return const Center(
              child: Text(
                'No attendance data available',
              ),
            );
          }

          final filteredRecords =
              attendance.records.where(
            (
              SessionAttendanceRecord
                  record,
            ) {
              final query =
                  _searchQuery
                      .trim()
                      .toLowerCase();

              final matchesSearch =
                  query.isEmpty ||
                      record.attendanceId
                          .toString()
                          .contains(
                            query,
                          ) ||
                      record.studentId
                          .toString()
                          .contains(
                            query,
                          );

              final matchesFilter =
                  _selectedFilter ==
                          'ALL' ||
                      record.status
                              .toUpperCase() ==
                          _selectedFilter;

              return matchesSearch &&
                  matchesFilter;
            },
          ).toList();

          return RefreshIndicator(
            onRefresh: () async {
              await provider
                  .loadSessionAttendance(
                widget.sessionId,
              );
            },
            child: ListView(
              padding:
                  const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Confirmed',
                        value: attendance
                            .confirmed
                            .toString(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Flagged',
                        value: attendance
                            .flagged
                            .toString(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Rejected',
                        value: attendance
                            .rejected
                            .toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller:
                      _searchController,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Search Attendance ID or Student ID',
                    prefixIcon:
                        Icon(Icons.search),
                    border:
                        OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery =
                          value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<
                    String>(
                  value:
                      _selectedFilter,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Status Filter',
                    border:
                        OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'ALL',
                      child: Text(
                        'ALL',
                      ),
                    ),
                    DropdownMenuItem(
                      value:
                          'CONFIRMED',
                      child: Text(
                        'CONFIRMED',
                      ),
                    ),
                    DropdownMenuItem(
                      value:
                          'FLAGGED',
                      child: Text(
                        'FLAGGED',
                      ),
                    ),
                    DropdownMenuItem(
                      value:
                          'REJECTED',
                      child: Text(
                        'REJECTED',
                      ),
                    ),
                  ],
                  onChanged: (
                    value,
                  ) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _selectedFilter =
                          value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Attendance Records',
                  style:
                      Theme.of(context)
                          .textTheme
                          .titleLarge,
                ),
                const SizedBox(height: 12),
                if (filteredRecords
                    .isEmpty)
                  const Card(
                    child: Padding(
                      padding:
                          EdgeInsets.all(
                        16,
                      ),
                      child: Text(
                        'No attendance records found',
                      ),
                    ),
                  ),
                ...filteredRecords.map(
                  (
                    SessionAttendanceRecord
                        record,
                  ) {
                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 8,
                      ),
                      child: ListTile(
                        title: Text(
                          'Attendance ID: ${record.attendanceId}',
                        ),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'Student ID: ${record.studentId}',
                            ),
                            Text(
                              'Status: ${record.status}',
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AttendanceDetailScreen(
                                attendanceId:
                                    record
                                        .attendanceId,
                              ),
                            ),
                          );
                        },
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

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 8,
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style:
                  Theme.of(context)
                      .textTheme
                      .headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}