// mobile_app/lib/features/profile/presentation/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_bootstrap.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/device_management_api_service.dart';
import 'profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(
            profileNotifierProvider.notifier,
          )
          .loadProfile();
    });
  }

  Future<void> _handleSelfUnbind(
    BuildContext context,
  ) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Reset Device',
              ),
              content: const Text(
                'This will remove the current device registration. '
                'You will be logged out and must log in again to register a new device. '
                'Do you want to continue?',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                      false,
                    );
                  },
                  child: const Text(
                    'Cancel',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                      true,
                    );
                  },
                  child: const Text(
                    'Reset Device',
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

    try {
      final service =
          DeviceManagementApiService(
        AppBootstrap.apiClient,
      );

      await service.selfUnbind();

      await ref
          .read(
            authNotifierProvider.notifier,
          )
          .logout();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Device reset successful. Please log in again.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      profileNotifierProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
        ),
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (state.error != null) {
            return Center(
              child: Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person_off,
                        size: 48,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      const Text(
                        'Unable to load profile',
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Text(
                        'Please try again later.',
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(
                                profileNotifierProvider
                                    .notifier,
                              )
                              .loadProfile();
                        },
                        child: const Text(
                          'Retry',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final profile = state.profile;

          if (profile == null) {
            return const Center(
              child: Text(
                'Unable to load profile',
              ),
            );
          }

          final role =
              profile.role.toLowerCase();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          role == 'admin'
                              ? 'Admin ID: ${profile.userId}'
                              : role == 'faculty'
                                  ? 'Faculty ID: ${profile.userId}'
                                  : 'Student ID: ${profile.userId}',
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          'Full Name: ${profile.fullName}',
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          'Email: ${profile.email}',
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          'Registered Device: ${profile.deviceId ?? 'Not Available'}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                if (role == 'student')
                  Material(
                    borderRadius:
                        BorderRadius.circular(8),
                    color:
                        Colors.blue.withValues(
                      alpha: 0.1,
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.all(16),
                      child: Text(
                        'Device changes require administrator approval.',
                      ),
                    ),
                  )
                else if (role == 'faculty')
                  Material(
                    borderRadius:
                        BorderRadius.circular(8),
                    color:
                        Colors.blue.withValues(
                      alpha: 0.1,
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .stretch,
                        children: [
                          const Text(
                            'You may reset your own device from Account Settings.',
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _handleSelfUnbind(
                                context,
                              );
                            },
                            child: const Text(
                              'Reset Device',
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (role == 'admin')
                  Material(
                    borderRadius:
                        BorderRadius.circular(8),
                    color:
                        Colors.blue.withValues(
                      alpha: 0.1,
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .stretch,
                        children: [
                          const Text(
                            'You can manage device access for all users.',
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _handleSelfUnbind(
                                context,
                              );
                            },
                            child: const Text(
                              'Reset My Device',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}