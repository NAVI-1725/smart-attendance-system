// mobile_app/lib/features/admin/presentation/faculty/faculty_management_screen.dart

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/admin_faculty.dart';
import '../admin_provider.dart';
import 'faculty_create_screen.dart';
import 'faculty_edit_screen.dart';

class FacultyManagementScreen
    extends ConsumerStatefulWidget {
  const FacultyManagementScreen({
    super.key,
  });

  @override
  ConsumerState<FacultyManagementScreen>
      createState() =>
          _FacultyManagementScreenState();
}

class _FacultyManagementScreenState
    extends ConsumerState<
        FacultyManagementScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        ref
            .read(adminProvider)
            .loadFaculty();
      },
    );
  }

  Future<void> _importFaculty() async {
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
          .importFaculty(filePath);

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
            'Column A → Faculty ID\n'
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

    final filteredFaculty =
        provider.faculty.where(
      (faculty) {
        return faculty.fullName
                .toLowerCase()
                .contains(_search) ||
            faculty.email
                .toLowerCase()
                .contains(_search);
      },
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Faculty Management',
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
            onPressed: _importFaculty,
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
                  const FacultyCreateScreen(),
            ),
          );

          if (mounted) {
            await ref
                .read(adminProvider)
                .loadFaculty();
          }
        },
        child: const Icon(
          Icons.add,
        ),
      ),
      body: provider.isLoading &&
              provider.faculty.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(adminProvider)
                    .loadFaculty();
              },
              child: provider
                      .faculty.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(
                          height: 200,
                        ),
                        Center(
                          child: Text(
                            'No faculty found',
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
                          filteredFaculty
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
                                  'Search faculty',
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

                        final AdminFaculty
                            faculty =
                            filteredFaculty[
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
                                  faculty
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
                                  faculty
                                      .email,
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  faculty
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
                                                    FacultyEditScreen(
                                              faculty:
                                                  faculty,
                                            ),
                                          ),
                                        );

                                        if (mounted) {
                                          await ref
                                              .read(
                                                adminProvider,
                                              )
                                              .loadFaculty();
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
                                                'Delete Faculty',
                                              ),
                                              content:
                                                  Text(
                                                'Delete ${faculty.fullName}?',
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
                                            .deleteFaculty(
                                              faculty.id,
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