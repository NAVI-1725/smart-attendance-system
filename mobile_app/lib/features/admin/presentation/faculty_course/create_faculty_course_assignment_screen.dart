// mobile_app/lib/features/admin/presentation/faculty_course/create_faculty_course_assignment_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/admin_course.dart';
import '../../models/admin_faculty.dart';
import '../admin_provider.dart';

class CreateFacultyCourseAssignmentScreen
    extends ConsumerStatefulWidget {
  const CreateFacultyCourseAssignmentScreen({
    super.key,
  });

  @override
  ConsumerState<
          CreateFacultyCourseAssignmentScreen>
      createState() =>
          _CreateFacultyCourseAssignmentScreenState();
}

class _CreateFacultyCourseAssignmentScreenState
    extends ConsumerState<
        CreateFacultyCourseAssignmentScreen> {
  int? _selectedFacultyId;
  int? _selectedCourseId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) async {
        final provider =
            ref.read(adminProvider);

        if (provider.faculty.isEmpty) {
          await provider.loadFaculty();
        }

        if (provider.courses.isEmpty) {
          await provider.loadCourses();
        }
      },
    );
  }

  Future<void> _assignFaculty() async {
    if (_selectedFacultyId == null ||
        _selectedCourseId == null) {
      return;
    }

    await ref
        .read(adminProvider)
        .createFacultyCourseAssignment(
          facultyId:
              _selectedFacultyId!,
          courseId:
              _selectedCourseId!,
        );

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        ref.watch(adminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assign Faculty',
        ),
      ),
      body: provider.isLoading &&
              provider.faculty.isEmpty &&
              provider.courses.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.all(
                16,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                children: [
                  Autocomplete<
                      AdminFaculty>(
                    displayStringForOption:
                        (
                      faculty,
                    ) {
                      return '${faculty.fullName} (${faculty.email})';
                    },
                    optionsBuilder:
                        (
                      TextEditingValue
                          textEditingValue,
                    ) {
                      if (textEditingValue
                          .text
                          .isEmpty) {
                        return provider
                            .faculty;
                      }

                      final query =
                          textEditingValue
                              .text
                              .toLowerCase();

                      return provider
                          .faculty
                          .where(
                        (
                          faculty,
                        ) {
                          return faculty
                                  .fullName
                                  .toLowerCase()
                                  .contains(
                                    query,
                                  ) ||
                              faculty
                                  .email
                                  .toLowerCase()
                                  .contains(
                                    query,
                                  );
                        },
                      );
                    },
                    onSelected:
                        (
                      AdminFaculty
                          faculty,
                    ) {
                      setState(() {
                        _selectedFacultyId =
                            faculty.id;
                      });
                    },
                    fieldViewBuilder:
                        (
                      context,
                      controller,
                      focusNode,
                      onFieldSubmitted,
                    ) {
                      return TextFormField(
                        controller:
                            controller,
                        focusNode:
                            focusNode,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Faculty',
                          hintText:
                              'Search faculty by name or email',
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Autocomplete<
                      AdminCourse>(
                    displayStringForOption:
                        (
                      course,
                    ) {
                      return '${course.courseCode} - ${course.courseName}';
                    },
                    optionsBuilder:
                        (
                      TextEditingValue
                          textEditingValue,
                    ) {
                      if (textEditingValue
                          .text
                          .isEmpty) {
                        return provider
                            .courses;
                      }

                      final query =
                          textEditingValue
                              .text
                              .toLowerCase();

                      return provider
                          .courses
                          .where(
                        (
                          course,
                        ) {
                          return course
                                  .courseCode
                                  .toLowerCase()
                                  .contains(
                                    query,
                                  ) ||
                              course
                                  .courseName
                                  .toLowerCase()
                                  .contains(
                                    query,
                                  );
                        },
                      );
                    },
                    onSelected:
                        (
                      AdminCourse
                          course,
                    ) {
                      setState(() {
                        _selectedCourseId =
                            course.id;
                      });
                    },
                    fieldViewBuilder:
                        (
                      context,
                      controller,
                      focusNode,
                      onFieldSubmitted,
                    ) {
                      return TextFormField(
                        controller:
                            controller,
                        focusNode:
                            focusNode,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Course',
                          hintText:
                              'Search course by code or name',
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  SizedBox(
                    height: 48,
                    child: provider
                            .isLoading
                        ? const Center(
                            child:
                                CircularProgressIndicator(),
                          )
                        : ElevatedButton(
                            onPressed:
                                _assignFaculty,
                            child:
                                const Text(
                              'Assign',
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}