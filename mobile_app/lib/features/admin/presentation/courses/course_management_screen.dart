// mobile_app/lib/features/admin/presentation/courses/course_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/admin_course.dart';
import '../admin_provider.dart';
import 'course_create_screen.dart';
import 'course_edit_screen.dart';

class CourseManagementScreen
    extends ConsumerStatefulWidget {
  const CourseManagementScreen({
    super.key,
  });

  @override
  ConsumerState<CourseManagementScreen>
      createState() =>
          _CourseManagementScreenState();
}

class _CourseManagementScreenState
    extends ConsumerState<
        CourseManagementScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        ref
            .read(adminProvider)
            .loadCourses();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        ref.watch(adminProvider);

    final filteredCourses =
        provider.courses.where(
      (course) {
        return course.courseCode
                .toLowerCase()
                .contains(_search) ||
            course.courseName
                .toLowerCase()
                .contains(_search);
      },
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Course Management',
        ),
      ),
      floatingActionButton:
          FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const CourseCreateScreen(),
            ),
          );

          if (mounted) {
            await ref
                .read(adminProvider)
                .loadCourses();
          }
        },
        child: const Icon(
          Icons.add,
        ),
      ),
      body: provider.isLoading &&
              provider.courses.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(adminProvider)
                    .loadCourses();
              },
              child: provider
                      .courses.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(
                          height: 200,
                        ),
                        Center(
                          child: Text(
                            'No courses found',
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
                      itemCount:
                          filteredCourses
                              .length +
                          1,
                      separatorBuilder:
                          (_, __) =>
                              const SizedBox(
                        height: 12,
                      ),
                      itemBuilder:
                          (
                        context,
                        index,
                      ) {
                        if (index == 0) {
                          return TextField(
                            decoration:
                                const InputDecoration(
                              prefixIcon:
                                  Icon(
                                Icons.search,
                              ),
                              hintText:
                                  'Search course',
                            ),
                            onChanged:
                                (value) {
                              setState(() {
                                _search =
                                    value
                                        .toLowerCase();
                              });
                            },
                          );
                        }

                        final AdminCourse
                            course =
                            filteredCourses[
                                index -
                                    1];

                        return Card(
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
                                  course
                                      .courseCode,
                                  style:
                                      Theme.of(
                                    context,
                                  )
                                          .textTheme
                                          .titleMedium,
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  course
                                      .courseName,
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .end,
                                  children: [
                                    TextButton.icon(
                                      onPressed:
                                          () async {
                                        await Navigator
                                            .push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) =>
                                                    CourseEditScreen(
                                              course:
                                                  course,
                                            ),
                                          ),
                                        );

                                        if (mounted) {
                                          await ref
                                              .read(
                                                adminProvider,
                                              )
                                              .loadCourses();
                                        }
                                      },
                                      icon:
                                          const Icon(
                                        Icons.edit,
                                      ),
                                      label:
                                          const Text(
                                        'Edit',
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    TextButton.icon(
                                      onPressed:
                                          () async {
                                        final bool?
                                            confirmed =
                                            await showDialog<
                                                bool>(
                                          context:
                                              context,
                                          builder:
                                              (
                                            context,
                                          ) {
                                            return AlertDialog(
                                              title:
                                                  const Text(
                                                'Delete Course',
                                              ),
                                              content:
                                                  Text(
                                                'Delete ${course.courseName}?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () {
                                                    Navigator.pop(
                                                      context,
                                                      false,
                                                    );
                                                  },
                                                  child:
                                                      const Text(
                                                    'Cancel',
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed:
                                                      () {
                                                    Navigator.pop(
                                                      context,
                                                      true,
                                                    );
                                                  },
                                                  child:
                                                      const Text(
                                                    'Delete',
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (confirmed !=
                                            true) {
                                          return;
                                        }

                                        await ref
                                            .read(
                                              adminProvider,
                                            )
                                            .deleteCourse(
                                              course.id,
                                            );
                                      },
                                      icon:
                                          const Icon(
                                        Icons.delete,
                                      ),
                                      label:
                                          const Text(
                                        'Delete',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}