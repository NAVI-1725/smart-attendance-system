// mobile_app/lib/features/admin/presentation/students/student_management_screen.dart

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/admin_student.dart';
import '../admin_provider.dart';
import 'student_create_screen.dart';
import 'student_edit_screen.dart';

class StudentManagementScreen
    extends ConsumerStatefulWidget {
  const StudentManagementScreen({
    super.key,
  });

  @override
  ConsumerState<StudentManagementScreen>
      createState() =>
          _StudentManagementScreenState();
}

class _StudentManagementScreenState
    extends ConsumerState<
        StudentManagementScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        ref
            .read(adminProvider)
            .loadStudents();
      },
    );
  }

  Future<void> _importStudents() async {
    final result =
        await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'xlsx',
        'xlsm',
      ],
    );

    if (result == null ||
        result.files.single.path == null) {
      return;
    }

    final filePath =
        result.files.single.path!;

    if (!mounted) return;

    try {
      final summary = await ref
          .read(adminProvider)
          .importStudents(filePath);

      if (!mounted) return;

      _showImportResultDialog(summary);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Import failed: ${e.toString()}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImportFormatDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Expected Excel Format',
          ),
          content: const Text(
            'Column A → Student ID\n'
            'Column B → Full Name\n'
            'Column C → Email\n'
            'Column D → Password',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showImportResultDialog(
    Map<String, dynamic> summary,
  ) {
    final int created =
        summary['created'] as int? ?? 0;

    final int skipped =
        summary['skipped'] as int? ?? 0;

    final List<dynamic> errors =
        summary['errors'] as List<dynamic>? ??
            [];

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Import Complete',
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Created : $created',
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.skip_next,
                      color: Colors.orange,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Skipped : $skipped',
                    ),
                  ],
                ),
                if (errors.isNotEmpty) ...[
                  const SizedBox(
                    height: 12,
                  ),
                  const Text(
                    'Errors:',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  ...errors.map(
                    (e) => Padding(
                      padding:
                          const EdgeInsets
                              .only(
                        bottom: 4,
                      ),
                      child: Text(
                        '• $e',
                        style:
                            const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        ref.watch(adminProvider);

    final filteredStudents =
        provider.students.where(
      (student) {
        return student.fullName
                .toLowerCase()
                .contains(_search) ||
            student.email
                .toLowerCase()
                .contains(_search);
      },
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Management',
        ),
        actions: [
          IconButton(
            onPressed: _showImportFormatDialog,
            icon: const Icon(
              Icons.info_outline,
            ),
            tooltip: 'Excel Format',
          ),
          IconButton(
            onPressed: _importStudents,
            icon: const Icon(
              Icons.upload_file,
            ),
            tooltip: 'Import Excel',
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const StudentCreateScreen(),
            ),
          );

          if (mounted) {
            await ref
                .read(adminProvider)
                .loadStudents();
          }
        },
        child: const Icon(
          Icons.add,
        ),
      ),
      body: provider.isLoading &&
              provider.students.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(adminProvider)
                    .loadStudents();
              },
              child: provider
                      .students.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(
                          height: 200,
                        ),
                        Center(
                          child: Text(
                            'No students found',
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
                          filteredStudents
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
                                  'Search student',
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

                        final AdminStudent
                            student =
                            filteredStudents[
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
                                  student
                                      .fullName,
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
                                  student
                                      .email,
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  student
                                          .isActive
                                      ? 'Active'
                                      : 'Inactive',
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
                                                    StudentEditScreen(
                                              student:
                                                  student,
                                            ),
                                          ),
                                        );

                                        if (mounted) {
                                          await ref
                                              .read(
                                                adminProvider,
                                              )
                                              .loadStudents();
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
                                                'Delete Student',
                                              ),
                                              content:
                                                  Text(
                                                'Delete ${student.fullName}?',
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
                                            .deleteStudent(
                                              student.id,
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