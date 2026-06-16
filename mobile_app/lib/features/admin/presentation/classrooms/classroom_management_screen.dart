// mobile_app/lib/features/admin/presentation/classrooms/classroom_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/classroom.dart';
import '../admin_provider.dart';
import 'create_classroom_screen.dart';
import 'edit_classroom_screen.dart';

class ClassroomManagementScreen extends ConsumerStatefulWidget {
  const ClassroomManagementScreen({super.key});

  @override
  ConsumerState<ClassroomManagementScreen> createState() =>
      _ClassroomManagementScreenState();
}

class _ClassroomManagementScreenState
    extends ConsumerState<ClassroomManagementScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider).loadClassrooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(adminProvider);

    final filteredClassrooms =
        provider.classrooms.where(
      (classroom) {
        return classroom.name
            .toLowerCase()
            .contains(_search);
      },
    ).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Classroom Management')),
      body: provider.isLoading && provider.classrooms.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await provider.loadClassrooms();
              },
              child: ListView.builder(
                itemCount: filteredClassrooms.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search classroom',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _search = value.toLowerCase();
                          });
                        },
                      ),
                    );
                  }

                  final Classroom classroom = filteredClassrooms[index - 1];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(classroom.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Latitude: ${classroom.latitude}'),
                          Text('Longitude: ${classroom.longitude}'),
                          Text('GPS Radius: ${classroom.gpsRadiusMeters} m'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditClassroomScreen(classroom: classroom),
                                ),
                              );

                              if (!mounted) {
                                return;
                              }

                              await provider.loadClassrooms();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await provider.deleteClassroom(classroom.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateClassroomScreen()),
          );

          if (!mounted) {
            return;
          }

          await ref.read(adminProvider).loadClassrooms();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}