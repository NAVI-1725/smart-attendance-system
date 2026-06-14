// mobile_app/lib/features/faculty/presentation/student_history_screen.dart

import 'package:flutter/material.dart';

import '../../../core/config/app_bootstrap.dart';
import '../data/course_api_service.dart';
import '../models/student_history.dart';

class StudentHistoryScreen extends StatefulWidget {
  final int studentId;
  final String studentName;

  const StudentHistoryScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<StudentHistoryScreen> createState() =>
      _StudentHistoryScreenState();
}

class _StudentHistoryScreenState
    extends State<StudentHistoryScreen> {
  late final CourseApiService _apiService;

  bool _isLoading = true;
  String? _error;

  List<StudentHistory> _history = [];

  @override
  void initState() {
    super.initState();

    _apiService = CourseApiService(
      AppBootstrap.apiClient,
    );

    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final history =
          await _apiService.getStudentHistory(
        widget.studentId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _history = history;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error =
            'Unable to load student history';
        _isLoading = false;
      });
    }
  }

  String _formatTimestamp(
    DateTime timestamp,
  ) {
    return timestamp
        .toLocal()
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.studentName,
        ),
      ),
      body: Builder(
        builder: (context) {
          if (_isLoading) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (_error != null) {
            return Center(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Text(_error!),
                  const SizedBox(
                    height: 12,
                  ),
                  ElevatedButton(
                    onPressed:
                        _loadHistory,
                    child: const Text(
                      'Retry',
                    ),
                  ),
                ],
              ),
            );
          }

          if (_history.isEmpty) {
            return const Center(
              child: Text(
                'No attendance history found',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadHistory,
            child: ListView.separated(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.all(
                12,
              ),
              itemCount:
                  _history.length,
              separatorBuilder:
                  (_, __) =>
                      const SizedBox(
                height: 8,
              ),
              itemBuilder:
                  (context, index) {
                final item =
                    _history[index];

                return Card(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      12,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          'Attendance ID: ${item.attendanceId}',
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Course Name: ${item.courseName}',
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Status: ${item.status}',
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Timestamp: ${_formatTimestamp(item.timestamp)}',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}