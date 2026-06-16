// mobile_app/lib/features/admin/presentation/courses/course_create_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../admin_provider.dart';

class CourseCreateScreen
    extends ConsumerStatefulWidget {
  const CourseCreateScreen({
    super.key,
  });

  @override
  ConsumerState<CourseCreateScreen>
      createState() =>
          _CourseCreateScreenState();
}

class _CourseCreateScreenState
    extends ConsumerState<
        CourseCreateScreen> {
  final _courseCodeController =
      TextEditingController();

  final _courseNameController =
      TextEditingController();

  @override
  void dispose() {
    _courseCodeController.dispose();
    _courseNameController.dispose();
    super.dispose();
  }

  Future<void> _createCourse() async {
    await ref
        .read(adminProvider)
        .createCourse(
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
          'Create Course',
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
                          _createCourse,
                      child:
                          const Text(
                        'Create Course',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}