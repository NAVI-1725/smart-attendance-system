// mobile_app/lib/features/admin/presentation/enrollments/create_enrollment_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/admin_course.dart';
import '../../models/admin_student.dart';
import '../admin_provider.dart';

class CreateEnrollmentScreen
    extends ConsumerStatefulWidget {
  const CreateEnrollmentScreen({
    super.key,
  });

  @override
  ConsumerState<CreateEnrollmentScreen>
      createState() =>
          _CreateEnrollmentScreenState();
}

class _CreateEnrollmentScreenState
    extends ConsumerState<CreateEnrollmentScreen> {
  int? _selectedStudentId;
  int? _selectedCourseId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        final provider = ref.read(adminProvider);

        if (provider.students.isEmpty) {
          await provider.loadStudents();
        }

        if (provider.courses.isEmpty) {
          await provider.loadCourses();
        }
      },
    );
  }

  Future<void> _createEnrollment() async {
    if (_selectedStudentId == null ||
        _selectedCourseId == null) {
      return;
    }

    await ref.read(adminProvider).createEnrollment(
      studentId: _selectedStudentId!,
      courseId: _selectedCourseId!,
    );

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(adminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Enrollment'),
      ),
      body: provider.isLoading &&
              provider.students.isEmpty &&
              provider.courses.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  Autocomplete<AdminStudent>(
                    displayStringForOption: (student) {
                      return '${student.fullName} (${student.email})';
                    },
                    optionsBuilder: (
                      TextEditingValue textEditingValue,
                    ) {
                      if (textEditingValue.text.isEmpty) {
                        return provider.students;
                      }

                      final query =
                          textEditingValue.text.toLowerCase();

                      return provider.students.where(
                        (student) {
                          return student.fullName
                                  .toLowerCase()
                                  .contains(query) ||
                              student.email
                                  .toLowerCase()
                                  .contains(query);
                        },
                      );
                    },
                    onSelected: (AdminStudent student) {
                      setState(() {
                        _selectedStudentId = student.id;
                      });
                    },
                    fieldViewBuilder: (
                      context,
                      controller,
                      focusNode,
                      onFieldSubmitted,
                    ) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Student',
                          hintText:
                              'Search student by name or email',
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Autocomplete<AdminCourse>(
                    displayStringForOption: (course) {
                      return '${course.courseCode} - ${course.courseName}';
                    },
                    optionsBuilder: (
                      TextEditingValue textEditingValue,
                    ) {
                      if (textEditingValue.text.isEmpty) {
                        return provider.courses;
                      }

                      final query =
                          textEditingValue.text.toLowerCase();

                      return provider.courses.where(
                        (course) {
                          return course.courseCode
                                  .toLowerCase()
                                  .contains(query) ||
                              course.courseName
                                  .toLowerCase()
                                  .contains(query);
                        },
                      );
                    },
                    onSelected: (AdminCourse course) {
                      setState(() {
                        _selectedCourseId = course.id;
                      });
                    },
                    fieldViewBuilder: (
                      context,
                      controller,
                      focusNode,
                      onFieldSubmitted,
                    ) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Course',
                          hintText:
                              'Search course by code or name',
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: provider.isLoading
                        ? const Center(
                            child:
                                CircularProgressIndicator(),
                          )
                        : ElevatedButton(
                            onPressed: _createEnrollment,
                            child: const Text(
                              'Enroll Student',
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}