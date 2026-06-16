// mobile_app\lib\features\admin\presentation\beacons\create_beacon_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../admin_provider.dart';

class CreateBeaconScreen extends ConsumerStatefulWidget {
  const CreateBeaconScreen({super.key});

  @override
  ConsumerState<CreateBeaconScreen> createState() =>
      _CreateBeaconScreenState();
}

class _CreateBeaconScreenState extends ConsumerState<CreateBeaconScreen> {
  final _formKey = GlobalKey<FormState>();

  final _classroomIdController = TextEditingController();
  final _beaconUuidController = TextEditingController();
  final _beaconNameController = TextEditingController();

  @override
  void dispose() {
    _classroomIdController.dispose();
    _beaconUuidController.dispose();
    _beaconNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(adminProvider).createBeacon(
          classroomId: int.parse(
            _classroomIdController.text.trim(),
          ),
          beaconUuid: _beaconUuidController.text.trim(),
          beaconName: _beaconNameController.text.trim().isEmpty
              ? null
              : _beaconNameController.text.trim(),
        );

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(adminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Beacon'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _classroomIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Classroom ID',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Classroom ID is required';
                  }

                  final classroomId = int.tryParse(value.trim());
                  if (classroomId == null || classroomId <= 0) {
                    return 'Enter a valid classroom ID';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _beaconUuidController,
                decoration: const InputDecoration(
                  labelText: 'Beacon UUID',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Beacon UUID is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _beaconNameController,
                decoration: const InputDecoration(
                  labelText: 'Beacon Name (Optional)',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : _submit,
                  child: const Text('Create Beacon'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
