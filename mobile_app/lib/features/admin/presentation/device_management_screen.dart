// mobile_app/lib/features/admin/presentation/device_management_screen.dart

import 'package:flutter/material.dart';

import '../../../core/config/app_bootstrap.dart';
import '../data/admin_device_api_service.dart';
import '../models/device_search_user.dart';

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
  final _searchController =
      TextEditingController();

  List<DeviceSearchUser> _users = [];

  DeviceSearchUser? _selectedUser;

  bool _isSearching = false;

  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(
    String query,
  ) async {
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      setState(() {
        _users = [];
        _selectedUser = null;
      });

      return;
    }

    setState(() {
      _isSearching = true;
      _selectedUser = null;
    });

    try {
      final apiService = AdminDeviceApiService(
        AppBootstrap.apiClient,
      );

      final results =
          await apiService.searchUsers(trimmed);

      if (!mounted) {
        return;
      }

      setState(() {
        _users = results;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Search failed. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _unbindDevice() async {
    if (_selectedUser == null) {
      return;
    }

    final user = _selectedUser!;

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Confirm Device Unbind',
              ),
              content: Text(
                'Unbind device for ${user.fullName}?',
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
      final apiService = AdminDeviceApiService(
        AppBootstrap.apiClient,
      );

      await apiService.unbindDevice(user.id);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Device unbound successfully',
          ),
        ),
      );

      _searchController.clear();

      setState(() {
        _users = [];
        _selectedUser = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            // Search field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText:
                    'Search Student / Faculty',
                border:
                    const OutlineInputBorder(),
                prefixIcon:
                    const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding:
                            EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : null,
              ),
              onChanged: _searchUsers,
            ),
            const SizedBox(height: 12),

            // Search results list
            if (_users.isNotEmpty &&
                _selectedUser == null)
              Expanded(
                child: Card(
                  child: ListView.separated(
                    itemCount: _users.length,
                    separatorBuilder:
                        (_, __) => const Divider(
                      height: 1,
                    ),
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final user = _users[index];

                      return ListTile(
                        title: Text(
                          user.fullName,
                        ),
                        subtitle: Text(
                          '${user.email}  •  ${user.role}',
                        ),
                        trailing: Text(
                          'ID: ${user.id}',
                          style:
                              Theme.of(context)
                                  .textTheme
                                  .bodySmall,
                        ),
                        onTap: () {
                          setState(() {
                            _selectedUser = user;
                            _users = [];
                          });
                        },
                      );
                    },
                  ),
                ),
              ),

            // No results message
            if (!_isSearching &&
                _searchController
                    .text.trim().isNotEmpty &&
                _users.isEmpty &&
                _selectedUser == null)
              const Padding(
                padding: EdgeInsets.only(
                  top: 8,
                ),
                child: Text(
                  'No users found.',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),

            // Selected user card + unbind button
            if (_selectedUser != null)
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected User',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: 'Name',
                        value:
                            _selectedUser!.fullName,
                      ),
                      const SizedBox(height: 6),
                      _InfoRow(
                        label: 'Email',
                        value:
                            _selectedUser!.email,
                      ),
                      const SizedBox(height: 6),
                      _InfoRow(
                        label: 'Role',
                        value:
                            _selectedUser!.role,
                      ),
                      const SizedBox(height: 6),
                      _InfoRow(
                        label: 'ID',
                        value: _selectedUser!.id
                            .toString(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedUser =
                                    null;
                              });
                            },
                            child: const Text(
                              'Change',
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
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
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            '$label:',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}