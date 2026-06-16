// mobile_app/lib/features/admin/presentation/faculty_course/faculty_course_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/faculty_course_assignment.dart';
import '../admin_provider.dart';
import 'create_faculty_course_assignment_screen.dart';

class FacultyCourseManagementScreen
    extends ConsumerStatefulWidget {
  const FacultyCourseManagementScreen({
    super.key,
  });

  @override
  ConsumerState<
          FacultyCourseManagementScreen>
      createState() =>
          _FacultyCourseManagementScreenState();
}

class _FacultyCourseManagementScreenState
    extends ConsumerState<
        FacultyCourseManagementScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        ref
            .read(adminProvider)
            .loadFacultyCourseAssignments();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        ref.watch(adminProvider);

    final filteredAssignments =
        provider.facultyCourseAssignments.where(
      (assignment) {
        return assignment.facultyName
                .toLowerCase()
                .contains(_search) ||
            assignment.courseCode
                .toLowerCase()
                .contains(_search) ||
            assignment.courseName
                .toLowerCase()
                .contains(_search);
      },
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Faculty Assignments',
        ),
      ),
      floatingActionButton:
          FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const CreateFacultyCourseAssignmentScreen(),
            ),
          );

          if (mounted) {
            await ref
                .read(adminProvider)
                .loadFacultyCourseAssignments();
          }
        },
        child: const Icon(
          Icons.add,
        ),
      ),
      body:
          provider.isLoading &&
                  provider
                      .facultyCourseAssignments
                      .isEmpty
              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(
                          adminProvider,
                        )
                        .loadFacultyCourseAssignments();
                  },
                  child: provider
                          .facultyCourseAssignments
                          .isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(
                              height: 200,
                            ),
                            Center(
                              child: Text(
                                'No assignments found',
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
                              filteredAssignments
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
                                      'Search assignment',
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

                            final FacultyCourseAssignment
                                assignment =
                                filteredAssignments[
                                    index - 1];

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
                                      assignment
                                          .facultyName,
                                      style:
                                          Theme.of(
                                        context,
                                      )
                                              .textTheme
                                              .titleMedium,
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      'Course Code: ${assignment.courseCode}',
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      'Course Name: ${assignment.courseName}',
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    Align(
                                      alignment:
                                          Alignment
                                              .centerRight,
                                      child:
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
                                                  'Delete Assignment',
                                                ),
                                                content:
                                                    const Text(
                                                  'Remove this faculty-course assignment?',
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
                                              .deleteFacultyCourseAssignment(
                                                assignment
                                                    .id,
                                              );
                                        },
                                        icon:
                                            const Icon(
                                          Icons
                                              .delete,
                                        ),
                                        label:
                                            const Text(
                                          'Delete',
                                        ),
                                      ),
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