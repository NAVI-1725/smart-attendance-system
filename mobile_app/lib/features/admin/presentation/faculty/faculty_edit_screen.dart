// mobile_app/lib/features/admin/presentation/faculty/faculty_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/admin_faculty.dart';
import '../admin_provider.dart';

class FacultyEditScreen
    extends ConsumerStatefulWidget {
  final AdminFaculty faculty;

  const FacultyEditScreen({
    super.key,
    required this.faculty,
  });

  @override
  ConsumerState<FacultyEditScreen>
      createState() =>
          _FacultyEditScreenState();
}

class _FacultyEditScreenState
    extends ConsumerState<
        FacultyEditScreen> {
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
      text: widget.faculty.fullName,
    );

    _emailController =
        TextEditingController(
      text: widget.faculty.email,
    );

    _isActive =
        widget.faculty.isActive;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateFaculty() async {
    await ref
        .read(adminProvider)
        .updateFaculty(
          facultyId:
              widget.faculty.id,
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
          'Edit Faculty',
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
                          _updateFaculty,
                      child:
                          const Text(
                        'Update Faculty',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}