// mobile_app/lib/features/admin/presentation/enrollments/enrollment_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../admin_provider.dart';
import 'create_enrollment_screen.dart';

class EnrollmentManagementScreen
    extends ConsumerStatefulWidget {
  const EnrollmentManagementScreen({
    super.key,
  });

  @override
  ConsumerState<EnrollmentManagementScreen>
      createState() =>
          _EnrollmentManagementScreenState();
}

class _EnrollmentManagementScreenState
    extends ConsumerState<EnrollmentManagementScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        ref
            .read(adminProvider)
            .loadEnrollments();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        ref.watch(adminProvider);

    final filteredEnrollments =
        provider.enrollments.where(
      (enrollment) {
        return enrollment.studentName
                .toLowerCase()
                .contains(_search) ||
            enrollment.courseCode
                .toLowerCase()
                .contains(_search) ||
            enrollment.courseName
                .toLowerCase()
                .contains(_search);
      },
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Enrollment Management',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await provider.loadEnrollments();
        },
        child: provider.isLoading &&
                provider.enrollments.isEmpty
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : provider.enrollments.isEmpty
                ? const Center(
                    child: Text(
                      'No enrollments found',
                    ),
                  )
                : ListView.builder(
                    itemCount:
                        filteredEnrollments
                                .length +
                            1,
                    itemBuilder:
                        (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding:
                              const EdgeInsets.all(
                            16,
                          ),
                          child: TextField(
                            decoration:
                                const InputDecoration(
                              prefixIcon:
                                  Icon(
                                Icons.search,
                              ),
                              hintText:
                                  'Search enrollment',
                            ),
                            onChanged:
                                (value) {
                              setState(() {
                                _search =
                                    value
                                        .toLowerCase();
                              });
                            },
                          ),
                        );
                      }

                      final enrollment =
                          filteredEnrollments[
                              index - 1];

                      return Card(
                        margin:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(
                            enrollment
                                .studentName,
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                enrollment
                                    .courseCode,
                              ),
                              Text(
                                enrollment
                                    .courseName,
                              ),
                            ],
                          ),
                          trailing:
                              IconButton(
                            icon: const Icon(
                              Icons.delete,
                            ),
                            onPressed:
                                () async {
                              await provider
                                  .deleteEnrollment(
                                enrollment.id,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton:
          FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const CreateEnrollmentScreen(),
            ),
          );

          if (mounted) {
            await ref
                .read(adminProvider)
                .loadEnrollments();
          }
        },
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}