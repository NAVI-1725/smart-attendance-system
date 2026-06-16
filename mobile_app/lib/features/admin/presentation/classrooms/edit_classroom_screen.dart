// mobile_app/lib/features/admin/presentation/classrooms/edit_classroom_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/classroom.dart';
import '../admin_provider.dart';

class EditClassroomScreen extends ConsumerStatefulWidget {
  final Classroom classroom;

  const EditClassroomScreen({super.key, required this.classroom});

  @override
  ConsumerState<EditClassroomScreen> createState() => _EditClassroomScreenState();
}

class _EditClassroomScreenState extends ConsumerState<EditClassroomScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;

  late final TextEditingController _latitudeController;

  late final TextEditingController _longitudeController;

  late final TextEditingController _gpsRadiusController;

  // A4: loading state for location button
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.classroom.name);

    _latitudeController = TextEditingController(
      text: widget.classroom.latitude.toString(),
    );

    _longitudeController = TextEditingController(
      text: widget.classroom.longitude.toString(),
    );

    _gpsRadiusController = TextEditingController(
      text: widget.classroom.gpsRadiusMeters.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _gpsRadiusController.dispose();
    super.dispose();
  }

  // A3 + A4: permission-safe location fetch with spinner
  Future<void> _fillCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location service is disabled',
            ),
          ),
        );

        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission denied',
            ),
          ),
        );

        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _latitudeController.text =
          position.latitude.toString();

      _longitudeController.text =
          position.longitude.toString();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location captured successfully',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to get location: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  Future<void> _updateClassroom() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(adminProvider).updateClassroom(
      classroomId: widget.classroom.id,
      name: _nameController.text.trim(),
      latitude: double.parse(_latitudeController.text.trim()),
      longitude: double.parse(_longitudeController.text.trim()),
      gpsRadiusMeters: int.parse(_gpsRadiusController.text.trim()),
    );

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(adminProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Classroom')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _latitudeController,
              decoration: const InputDecoration(labelText: 'Latitude'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Latitude is required';
                }

                final latitude = double.tryParse(value.trim());

                if (latitude == null) {
                  return 'Invalid latitude';
                }

                if (latitude < -90 || latitude > 90) {
                  return 'Latitude must be between -90 and 90';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isGettingLocation ? null : _fillCurrentLocation,
              // A4: spinner while fetching location
              icon: _isGettingLocation
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.my_location),
              label: const Text(
                'Use Current Location',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _longitudeController,
              decoration: const InputDecoration(labelText: 'Longitude'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Longitude is required';
                }

                final longitude = double.tryParse(value.trim());

                if (longitude == null) {
                  return 'Invalid longitude';
                }

                if (longitude < -180 || longitude > 180) {
                  return 'Longitude must be between -180 and 180';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _gpsRadiusController,
              decoration: const InputDecoration(labelText: 'GPS Radius'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'GPS Radius is required';
                }

                final radius = int.tryParse(value.trim());

                if (radius == null) {
                  return 'Invalid GPS Radius';
                }

                if (radius <= 0) {
                  return 'GPS Radius must be greater than 0';
                }

                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: provider.isLoading ? null : _updateClassroom,
              child: const Text('Update Classroom'),
            ),
          ],
        ),
      ),
    );
  }
}