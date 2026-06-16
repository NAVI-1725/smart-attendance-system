// mobile_app/lib/features/admin/presentation/students/student_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/admin_student.dart';
import '../admin_provider.dart';

class StudentEditScreen
    extends ConsumerStatefulWidget {
  final AdminStudent student;

  const StudentEditScreen({
    super.key,
    required this.student,
  });

  @override
  ConsumerState<StudentEditScreen>
      createState() =>
          _StudentEditScreenState();
}

class _StudentEditScreenState
    extends ConsumerState<
        StudentEditScreen> {
  late final TextEditingController
      _fullNameController;

  late final TextEditingController
      _emailController;

  late bool _isActive;

  @override
  void initState() {
    super.initState();

    _fullNameController =
        TextEditingController(
      text: widget.student.fullName,
    );

    _emailController =
        TextEditingController(
      text: widget.student.email,
    );

    _isActive =
        widget.student.isActive;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateStudent() async {
    await ref
        .read(adminProvider)
        .updateStudent(
          studentId:
              widget.student.id,
          fullName:
              _fullNameController.text,
          email:
              _emailController.text,
          isActive: _isActive,
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
          'Edit Student',
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller:
                  _fullNameController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Full Name',
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            TextField(
              controller:
                  _emailController,
              decoration:
                  const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            SwitchListTile(
              title: const Text(
                'Active',
              ),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
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
                          _updateStudent,
                      child:
                          const Text(
                        'Update Student',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}