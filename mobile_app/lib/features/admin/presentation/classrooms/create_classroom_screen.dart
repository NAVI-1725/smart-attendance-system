// mobile_app/lib/features/admin/presentation/classrooms/create_classroom_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../admin_provider.dart';

class CreateClassroomScreen extends ConsumerStatefulWidget {
  const CreateClassroomScreen({super.key});

  @override
  ConsumerState<CreateClassroomScreen> createState() =>
      _CreateClassroomScreenState();
}

class _CreateClassroomScreenState extends ConsumerState<CreateClassroomScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _latitudeController = TextEditingController();

  final TextEditingController _longitudeController = TextEditingController();

  final TextEditingController _gpsRadiusController = TextEditingController();

  // A4: loading state for location button
  bool _isGettingLocation = false;

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
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      print('LOCATION SERVICE ENABLED: $serviceEnabled');

      if (!serviceEnabled) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location service is disabled')),
        );

        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      print('INITIAL PERMISSION: $permission');

      print(
        'SERVICE STATUS: '
        '${await Geolocator.isLocationServiceEnabled()}',
      );

      print(
        'APP CAN REQUEST LOCATION',
      );

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        print('AFTER REQUEST PERMISSION: $permission');
      }

      if (permission == LocationPermission.denied) {
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

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission permanently denied. Open Settings and enable Location.',
            ),
          ),
        );

        await Geolocator.openAppSettings();

        return;
      }

      print('ATTEMPTING LOCATION FETCH');

      print(
        'PERMISSION BEFORE FETCH: $permission',
      );

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('LAT=${position.latitude}');

      print('LON=${position.longitude}');

      _latitudeController.text = position.latitude.toString();

      _longitudeController.text = position.longitude.toString();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location captured successfully')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to get location: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  Future<void> _createClassroom() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(adminProvider)
        .createClassroom(
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
      appBar: AppBar(title: const Text('Create Classroom')),
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
            ElevatedButton.icon(
              onPressed: _isGettingLocation ? null : _fillCurrentLocation,
              // A4: spinner while fetching location
              icon: _isGettingLocation
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: const Text('Use Current Location'),
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
              onPressed: provider.isLoading ? null : _createClassroom,
              child: const Text('Create Classroom'),
            ),
          ],
        ),
      ),
    );
  }
}