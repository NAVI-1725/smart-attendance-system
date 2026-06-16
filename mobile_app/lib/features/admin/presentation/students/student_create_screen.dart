// mobile_app/lib/features/admin/presentation/students/student_create_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../admin_provider.dart';

class StudentCreateScreen
    extends ConsumerStatefulWidget {
  const StudentCreateScreen({
    super.key,
  });

  @override
  ConsumerState<StudentCreateScreen>
      createState() =>
          _StudentCreateScreenState();
}

class _StudentCreateScreenState
    extends ConsumerState<
        StudentCreateScreen> {
  final _fullNameController =
      TextEditingController();

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createStudent() async {
    await ref
        .read(adminProvider)
        .createStudent(
          fullName:
              _fullNameController.text,
          email:
              _emailController.text,
          password:
              _passwordController.text,
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
          'Create Student',
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
            TextField(
              controller:
                  _passwordController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Password',
              ),
              obscureText: true,
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
                          _createStudent,
                      child:
                          const Text(
                        'Create Student',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}