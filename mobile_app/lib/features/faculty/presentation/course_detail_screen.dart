// mobile_app/lib/features/faculty/presentation/course_detail_screen.dart

import 'package:flutter/material.dart';

import '../../../core/config/app_bootstrap.dart';
import '../data/course_api_service.dart';
import '../data/faculty_api_service.dart';
import '../models/course_detail.dart';
import '../models/course_student.dart';
import 'session_monitor_screen.dart';
import 'start_session_dialog.dart';
import 'student_history_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final int courseId;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
  });

  @override
  State<CourseDetailScreen> createState() =>
      _CourseDetailScreenState();
}

class _CourseDetailScreenState
    extends State<CourseDetailScreen> {
  late final CourseApiService _apiService;

  bool _isLoading = true;
  String? _error;

  CourseDetail? _courseDetail;

  List<CourseStudent> _students = [];

  String _searchQuery = '';

  // Risk filter: null = ALL, otherwise 'Good', 'Warning', 'Risk'
  String? _riskFilter;

  @override
  void initState() {
    super.initState();

    _apiService = CourseApiService(
      AppBootstrap.apiClient,
    );

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final detail =
          await _apiService.getCourseDetail(
        widget.courseId,
      );

      final students =
          await _apiService.getCourseStudents(
        widget.courseId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _courseDetail = detail;
        _students = students;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = 'Unable to load course';
        _isLoading = false;
      });
    }
  }

  double get _averageAttendance {
    if (_students.isEmpty) {
      return 0.0;
    }

    final sum = _students.fold<double>(
      0.0,
      (acc, s) => acc + s.attendancePercentage,
    );

    return sum / _students.length;
  }

  int get _below75Count {
    return _students
        .where((s) => s.attendancePercentage < 75)
        .length;
  }

  int get _below60Count {
    return _students
        .where((s) => s.attendancePercentage < 60)
        .length;
  }

  List<CourseStudent> get _filteredStudents {
    List<CourseStudent> result = _students;

    // Apply risk filter first
    if (_riskFilter != null) {
      result = result.where((student) {
        return _getAttendanceStatus(
              student.attendancePercentage,
            ) ==
            _riskFilter;
      }).toList();
    }

    // Then apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();

      result = result.where((student) {
        return student.studentName
                .toLowerCase()
                .contains(query) ||
            student.studentId
                .toString()
                .toLowerCase()
                .contains(query);
      }).toList();
    }

    return result;
  }

  String _getAttendanceStatus(
    double percentage,
  ) {
    if (percentage >= 75) {
      return 'Good';
    } else if (percentage >= 60) {
      return 'Warning';
    } else {
      return 'Risk';
    }
  }

  Color _getAttendanceStatusColor(
    String status,
  ) {
    switch (status) {
      case 'Good':
        return Colors.green;
      case 'Warning':
        return Colors.orange;
      case 'Risk':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Course Detail',
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
                    onPressed: _loadData,
                    child: const Text(
                      'Retry',
                    ),
                  ),
                ],
              ),
            );
          }

          final detail = _courseDetail;

          if (detail == null) {
            return const Center(
              child: Text(
                'Course not found',
              ),
            );
          }

          final filteredStudents =
              _filteredStudents;

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              padding:
                  const EdgeInsets.all(
                16,
              ),
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
                          detail.courseName,
                          style:
                              Theme.of(
                            context,
                          ).textTheme.titleLarge,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Course Code: ${detail.courseCode}',
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Student Count: ${detail.studentCount}',
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Active Session: ${detail.activeSession ? "YES" : "NO"}',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                // Session UI: show Start Session only when no active session;
                // show Active Session ID, Monitor Session, Close Session when active.
                if (!detail.activeSession) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final result =
                            await showDialog<bool>(
                          context: context,
                          builder: (_) =>
                              StartSessionDialog(
                            courseId:
                                detail.courseId,
                          ),
                        );

                        if (result == true) {
                          await _loadData();
                        }
                      },
                      child: const Text(
                        'Start Session',
                      ),
                    ),
                  ),
                ] else ...[
                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        12,
                      ),
                      child: Text(
                        'Active Session ID: ${detail.activeSessionId}',
                        style:
                            Theme.of(
                          context,
                        ).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SessionMonitorScreen(
                                  sessionId:
                                      detail
                                          .activeSessionId!,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Monitor Session',
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await FacultyApiService(
                              AppBootstrap
                                  .apiClient,
                            ).closeSession(
                              detail
                                  .activeSessionId!,
                            );

                            await _loadData();
                          },
                          child: const Text(
                            'Close Session',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(
                  height: 24,
                ),

                // Search bar
                TextField(
                  decoration:
                      const InputDecoration(
                    hintText:
                        'Search by name or ID...',
                    prefixIcon:
                        Icon(Icons.search),
                    border:
                        OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),

                const SizedBox(
                  height: 12,
                ),

                // Risk filter chips: ALL / GOOD / WARNING / RISK
                SingleChildScrollView(
                  scrollDirection:
                      Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text(
                          'All',
                        ),
                        selected:
                            _riskFilter == null,
                        onSelected: (_) {
                          setState(() {
                            _riskFilter = null;
                          });
                        },
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      FilterChip(
                        label: const Text(
                          'Good',
                        ),
                        selected:
                            _riskFilter == 'Good',
                        selectedColor:
                            Colors.green
                                .withOpacity(
                          0.2,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _riskFilter =
                                _riskFilter ==
                                        'Good'
                                    ? null
                                    : 'Good';
                          });
                        },
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      FilterChip(
                        label: const Text(
                          'Warning',
                        ),
                        selected: _riskFilter ==
                            'Warning',
                        selectedColor:
                            Colors.orange
                                .withOpacity(
                          0.2,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _riskFilter =
                                _riskFilter ==
                                        'Warning'
                                    ? null
                                    : 'Warning';
                          });
                        },
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      FilterChip(
                        label: const Text(
                          'Risk',
                        ),
                        selected:
                            _riskFilter == 'Risk',
                        selectedColor:
                            Colors.red
                                .withOpacity(
                          0.2,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _riskFilter =
                                _riskFilter ==
                                        'Risk'
                                    ? null
                                    : 'Risk';
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                // Analytics section
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
                          'Analytics',
                          style:
                              Theme.of(
                            context,
                          ).textTheme.titleMedium,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            const Text(
                              'Average Attendance',
                            ),
                            Text(
                              '${_averageAttendance.toStringAsFixed(2)}%',
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            const Text(
                              'Students Below 75%',
                            ),
                            Text(
                              '$_below75Count',
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            const Text(
                              'Students Below 60%',
                            ),
                            Text(
                              '$_below60Count',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                Text(
                  'Students',
                  style:
                      Theme.of(
                    context,
                  ).textTheme.titleLarge,
                ),

                const SizedBox(
                  height: 12,
                ),

                if (filteredStudents.isEmpty)
                  const Card(
                    child: Padding(
                      padding:
                          EdgeInsets.all(
                        16,
                      ),
                      child: Text(
                        'No students enrolled',
                      ),
                    ),
                  ),

                ...filteredStudents.map(
                  (student) {
                    final status =
                        _getAttendanceStatus(
                      student
                          .attendancePercentage,
                    );

                    final statusColor =
                        _getAttendanceStatusColor(
                      status,
                    );

                    return Card(
                      child: ListTile(
                        title: Text(
                          student.studentName,
                        ),
                        subtitle: Text(
                          'Attendance: ${student.attendancePercentage.toStringAsFixed(2)}%',
                        ),
                        trailing: Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: statusColor
                                    .withOpacity(
                                  0.15,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  12,
                                ),
                                border:
                                    Border.all(
                                  color:
                                      statusColor,
                                ),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color:
                                      statusColor,
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            const Icon(
                              Icons.chevron_right,
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  StudentHistoryScreen(
                                studentId:
                                    student
                                        .studentId,
                                studentName:
                                    student
                                        .studentName,
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