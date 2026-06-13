// mobile_app/lib/features/admin/presentation/device_management_screen.dart

import 'package:flutter/material.dart';

import '../../../core/config/app_bootstrap.dart';
import '../data/admin_device_api_service.dart';

class DeviceManagementScreen extends StatefulWidget {
  const DeviceManagementScreen({
    super.key,
  });

  @override
  State<DeviceManagementScreen> createState() =>
      _DeviceManagementScreenState();
}

class _DeviceManagementScreenState
    extends State<DeviceManagementScreen> {
  final _formKey = GlobalKey<FormState>();

  final _userIdController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _unbindDevice() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userId = int.parse(
      _userIdController.text.trim(),
    );

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Confirm Device Unbind',
              ),
              content: Text(
                'Unbind the active device for user ID $userId?',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      false,
                    );
                  },
                  child: const Text(
                    'Cancel',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      true,
                    );
                  },
                  child: const Text(
                    'Unbind',
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService =
          AdminDeviceApiService(
        AppBootstrap.apiClient,
      );

      await apiService.unbindDevice(
        userId,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Device unbound successfully',
          ),
        ),
      );

      _userIdController.clear();
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to unbind device',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Device Management',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              Card(
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
                      const Text(
                        'Unbind User Device',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      const Text(
                        'Enter the User ID of the student, faculty member, or administrator whose device access should be reset.',
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        controller:
                            _userIdController,
                        keyboardType:
                            TextInputType.number,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'User ID',
                          border:
                              OutlineInputBorder(),
                        ),
                        validator: (
                          value,
                        ) {
                          final text =
                              value?.trim() ??
                                  '';

                          if (text.isEmpty) {
                            return 'Enter a valid user ID';
                          }

                          final id =
                              int.tryParse(
                            text,
                          );

                          if (id == null ||
                              id <= 0) {
                            return 'Enter a valid user ID';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        width:
                            double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _isLoading
                                  ? null
                                  : _unbindDevice,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                  ),
                                )
                              : const Text(
                                  'Unbind Device',
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}