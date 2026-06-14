// mobile_app/lib/features/faculty/presentation/faculty_courses_screen.dart

import 'package:flutter/material.dart';

import '../../../core/config/app_bootstrap.dart';
import '../data/course_api_service.dart';
import '../models/faculty_course.dart';
import 'course_detail_screen.dart';

class FacultyCoursesScreen extends StatefulWidget {
  const FacultyCoursesScreen({
    super.key,
  });

  @override
  State<FacultyCoursesScreen> createState() =>
      _FacultyCoursesScreenState();
}

class _FacultyCoursesScreenState
    extends State<FacultyCoursesScreen> {
  late final CourseApiService _apiService;

  bool _isLoading = true;
  String? _error;

  List<FacultyCourse> _courses = [];

  String _searchQuery = '';

  List<FacultyCourse> get _filteredCourses {
    if (_searchQuery.trim().isEmpty) {
      return _courses;
    }

    final query =
        _searchQuery.trim().toLowerCase();

    return _courses.where((course) {
      return course.courseCode
              .toLowerCase()
              .contains(query) ||
          course.courseName
              .toLowerCase()
              .contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    _apiService = CourseApiService(
      AppBootstrap.apiClient,
    );

    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final courses =
          await _apiService.getCourses();

      if (!mounted) {
        return;
      }

      setState(() {
        _courses = courses;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = 'Unable to load courses';
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _loadCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Courses',
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
                        _loadCourses,
                    child: const Text(
                      'Retry',
                    ),
                  ),
                ],
              ),
            );
          }

          if (_courses.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Text(
                    'No Courses Assigned',
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    'Contact Administrator',
                  ),
                ],
              ),
            );
          }

          final filteredCourses =
              _filteredCourses;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding:
                  const EdgeInsets.all(
                12,
              ),
              children: [
                TextField(
                  decoration:
                      const InputDecoration(
                    hintText:
                        'Search courses...',
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
                const SizedBox(
                  height: 12,
                ),
                if (filteredCourses.isEmpty)
                  const Card(
                    child: Padding(
                      padding:
                          EdgeInsets.all(
                        16,
                      ),
                      child: Text(
                        'No matching courses found',
                      ),
                    ),
                  ),
                ...filteredCourses.map(
                  (course) {
                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.all(
                          16,
                        ),
                        title: Text(
                          course.courseName,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding:
                              const EdgeInsets.only(
                            top: 8,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              Text(
                                'Course Code: ${course.courseCode}',
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                'Students: ${course.studentCount}',
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: course
                                          .activeSession
                                      ? Colors
                                          .green
                                          .withOpacity(
                                          0.15,
                                        )
                                      : Colors
                                          .grey
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
                                    color: course
                                            .activeSession
                                        ? Colors
                                            .green
                                        : Colors
                                            .grey,
                                  ),
                                ),
                                child: Text(
                                  course.activeSession
                                      ? 'ACTIVE'
                                      : 'INACTIVE',
                                  style:
                                      TextStyle(
                                    color: course
                                            .activeSession
                                        ? Colors
                                            .green
                                        : Colors
                                            .grey,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    fontSize:
                                        12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing:
                            const Icon(
                          Icons.chevron_right,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CourseDetailScreen(
                                courseId:
                                    course
                                        .courseId,
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