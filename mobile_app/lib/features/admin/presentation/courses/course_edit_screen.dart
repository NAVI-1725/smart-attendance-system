// mobile_app/lib/features/admin/presentation/courses/course_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/admin_course.dart';
import '../admin_provider.dart';

class CourseEditScreen
    extends ConsumerStatefulWidget {
  final AdminCourse course;

  const CourseEditScreen({
    super.key,
    required this.course,
  });

  @override
  ConsumerState<CourseEditScreen>
      createState() =>
          _CourseEditScreenState();
}

class _CourseEditScreenState
    extends ConsumerState<
        CourseEditScreen> {
  late final TextEditingController
      _courseCodeController;

  late final TextEditingController
      _courseNameController;

  @override
  void initState() {
    super.initState();

    _courseCodeController =
        TextEditingController(
      text: widget.course.courseCode,
    );

    _courseNameController =
        TextEditingController(
      text: widget.course.courseName,
    );
  }

  @override
  void dispose() {
    _courseCodeController.dispose();
    _courseNameController.dispose();
    super.dispose();
  }

  Future<void> _updateCourse() async {
    await ref
        .read(adminProvider)
        .updateCourse(
          courseId: widget.course.id,
          courseCode:
              _courseCodeController.text,
          courseName:
              _courseNameController.text,
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
          'Edit Course',
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller:
                  _courseCodeController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Course Code',
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            TextField(
              controller:
                  _courseNameController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Course Name',
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            SizedBox(
              width:
                  double.infinity,
              height: 48,
              child: provider
                      .isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      onPressed:
                          _updateCourse,
                      child:
                          const Text(
                        'Update Course',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}