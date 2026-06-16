// mobile_app\lib\features\admin\presentation\beacons\edit_beacon_screen.dartmobile_app\lib\features\admin\presentation\beacons\edit_beacon_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/admin_beacon.dart';
import '../admin_provider.dart';

class EditBeaconScreen extends ConsumerStatefulWidget {
  final AdminBeacon beacon;

  const EditBeaconScreen({
    super.key,
    required this.beacon,
  });

  @override
  ConsumerState<EditBeaconScreen> createState() =>
      _EditBeaconScreenState();
}

class _EditBeaconScreenState extends ConsumerState<EditBeaconScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _classroomIdController;
  late final TextEditingController _beaconUuidController;
  late final TextEditingController _beaconNameController;

  late bool _isActive;

  @override
  void initState() {
    super.initState();

    _classroomIdController = TextEditingController(
      text: widget.beacon.classroomId.toString(),
    );

    _beaconUuidController = TextEditingController(
      text: widget.beacon.beaconUuid,
    );

    _beaconNameController = TextEditingController(
      text: widget.beacon.beaconName ?? '',
    );

    _isActive = widget.beacon.isActive;
  }

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

    await ref.read(adminProvider).updateBeacon(
          beaconId: widget.beacon.id,
          classroomId: int.parse(_classroomIdController.text.trim()),
          beaconUuid: _beaconUuidController.text.trim(),
          beaconName: _beaconNameController.text.trim().isEmpty
              ? null
              : _beaconNameController.text.trim(),
          isActive: _isActive,
        );

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(adminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Beacon'),
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
                  labelText: 'Beacon Name',
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : _submit,
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
