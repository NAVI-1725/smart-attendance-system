// mobile_app/lib/features/faculty/presentation/start_session_dialog.dart

import 'package:flutter/material.dart';

import '../../../core/config/app_bootstrap.dart';
import '../data/faculty_api_service.dart';
import '../models/classroom.dart';

class StartSessionDialog extends StatefulWidget {
  final int courseId;

  const StartSessionDialog({super.key, required this.courseId});

  @override
  State<StartSessionDialog> createState() => _StartSessionDialogState();
}

class _StartSessionDialogState extends State<StartSessionDialog> {
  late final FacultyApiService _apiService;

  bool _isLoading = true;
  bool _isSubmitting = false;

  String? _error;

  List<Classroom> _classrooms = [];

  Classroom? _selectedClassroom;

  int _selectedDuration = 15;

  static const List<int> _durations = [5, 10, 15, 20, 30, 60];

  @override
  void initState() {
    super.initState();

    _apiService = FacultyApiService(AppBootstrap.apiClient);

    _loadClassrooms();
  }

  Future<void> _loadClassrooms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final classrooms = await _apiService.getClassrooms();

      print('CLASSROOM COUNT: ${classrooms.length}');

      for (final classroom in classrooms) {
        print(
          'CLASSROOM => '
          'id=${classroom.id}, '
          'name=${classroom.name}',
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _classrooms = classrooms;

        if (classrooms.isNotEmpty) {
          _selectedClassroom = classrooms.first;
        }

        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = 'Unable to load classrooms';
        _isLoading = false;
      });
    }
  }

  Future<void> _startSession() async {
    if (_selectedClassroom == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _apiService.startSession(
        courseId: widget.courseId,
        classroomId: _selectedClassroom!.id,
        durationMinutes: _selectedDuration,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to start session')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Start Session'),
      content: SizedBox(
        width: 400,
        child: Builder(
          builder: (context) {
            if (_isLoading) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (_error != null) {
              return SizedBox(
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadClassrooms,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (_classrooms.isEmpty) {
              return const SizedBox(
                height: 120,
                child: Center(child: Text('No classrooms available')),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Classroom'),
                const SizedBox(height: 8),
                DropdownButtonFormField<Classroom>(
                  value: _selectedClassroom,
                  items: _classrooms.map((classroom) {
                    return DropdownMenuItem<Classroom>(
                      value: classroom,
                      child: Text(classroom.name),
                    );
                  }).toList(),
                  onChanged: (classroom) {
                    setState(() {
                      _selectedClassroom = classroom;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Duration (minutes)'),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _selectedDuration,
                  items: _durations.map((duration) {
                    return DropdownMenuItem<int>(
                      value: duration,
                      child: Text('$duration minutes'),
                    );
                  }).toList(),
                  onChanged: (duration) {
                    if (duration == null) {
                      return;
                    }

                    setState(() {
                      _selectedDuration = duration;
                    });
                  },
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () {
                  Navigator.of(context).pop(false);
                },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _startSession,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Start Session'),
        ),
      ],
    );
  }
}
