// mobile_app\lib\features\admin\presentation\beacons\beacon_management_screen.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:io';

import '../../models/admin_beacon.dart';
import '../admin_provider.dart';
import 'create_beacon_screen.dart';
import 'edit_beacon_screen.dart';

class BeaconManagementScreen extends ConsumerStatefulWidget {
  const BeaconManagementScreen({super.key});

  @override
  ConsumerState<BeaconManagementScreen> createState() =>
      _BeaconManagementScreenState();
}

class _BeaconManagementScreenState
    extends ConsumerState<BeaconManagementScreen> {
  String _search = '';

  Future<void> _importBeacons() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'xlsx',
          'xls',
        ],
      );

      if (result == null ||
          result.files.isEmpty ||
          result.files.first.path == null) {
        return;
      }

      await ref.read(adminProvider).importBeacons(
            File(
              result.files.first.path!,
            ),
          );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Beacon import completed successfully',
          ),
        ),
      );

      await ref.read(adminProvider).loadBeacons();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        ref.read(adminProvider).loadBeacons();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(adminProvider);

    final filteredBeacons =
        provider.beacons.where(
      (beacon) {
        return (beacon.beaconName ?? '')
                .toLowerCase()
                .contains(_search) ||
            beacon.beaconUuid
                .toLowerCase()
                .contains(_search);
      },
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beacon Management'),
        actions: [
          IconButton(
            onPressed: _importBeacons,
            icon: const Icon(
              Icons.upload_file,
            ),
            tooltip: 'Import Beacons',
          ),
        ],
      ),
      body: provider.isLoading && provider.beacons.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await provider.loadBeacons();
              },
              child: ListView.builder(
                itemCount: filteredBeacons.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search beacon',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _search = value.toLowerCase();
                          });
                        },
                      ),
                    );
                  }

                  final AdminBeacon beacon = filteredBeacons[index - 1];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(
                        beacon.beaconName?.trim().isNotEmpty == true
                            ? beacon.beaconName!
                            : 'Unnamed Beacon',
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('UUID: ${beacon.beaconUuid}'),
                          Text('Classroom ID: ${beacon.classroomId}'),
                          Text(
                            'Status: ${beacon.isActive ? 'Active' : 'Inactive'}',
                          ),
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
                                  builder: (_) => EditBeaconScreen(
                                    beacon: beacon,
                                  ),
                                ),
                              );

                              if (!mounted) return;

                              await provider.loadBeacons();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Delete Beacon'),
                                    content: const Text(
                                      'Are you sure you want to delete this beacon?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, false);
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context, true);
                                        },
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirmed != true) return;

                              await provider.deleteBeacon(beacon.id);
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
            MaterialPageRoute(
              builder: (_) => const CreateBeaconScreen(),
            ),
          );

          if (!mounted) return;

          await ref.read(adminProvider).loadBeacons();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}