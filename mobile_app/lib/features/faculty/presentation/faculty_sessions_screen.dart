// mobile_app/lib/features/faculty/presentation/faculty_sessions_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/faculty_session.dart';
import 'faculty_provider.dart';
import 'session_monitor_screen.dart';

class FacultySessionsScreen
    extends ConsumerStatefulWidget {
  const FacultySessionsScreen({
    super.key,
  });

  @override
  ConsumerState<FacultySessionsScreen>
      createState() =>
          _FacultySessionsScreenState();
}

class _FacultySessionsScreenState
    extends ConsumerState<FacultySessionsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        ref
            .read(facultyProvider)
            .loadSessions();
      },
    );
  }

  Future<void> _closeSession(
    FacultySession session,
  ) async {
    await ref
        .read(facultyProvider)
        .closeSession(
          session.sessionId,
        );

    if (!mounted) {
      return;
    }

    await ref
        .read(facultyProvider)
        .loadSessions();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Session closed successfully',
        ),
      ),
    );
  }

  Future<void> _confirmAndDeleteSession(
    FacultySession session,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Delete Session?',
        ),
        content: const Text(
          'If This session contains no attendance '
          'records and will be permanently removed.'
          'Else records cant be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text(
              'Cancel',
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    if (!mounted) {
      return;
    }

    try {
      await ref
          .read(facultyProvider)
          .deleteSession(
            session.sessionId,
          );

      if (!mounted) {
        return;
      }

      await ref
          .read(facultyProvider)
          .loadSessions();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Session deleted successfully',
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
            e is Exception
                ? e.toString().replaceFirst(
                      'Exception: ',
                      '',
                    )
                : 'Unable to delete session',
          ),
        ),
      );
    }
  }

  String _formatDateTime(
    DateTime? value,
  ) {
    if (value == null) {
      return '-';
    }

    return value.toLocal().toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Faculty Sessions',
        ),
      ),
      body: Consumer(
        builder: (
          context,
          ref,
          _,
        ) {
          final provider =
              ref.watch(
                facultyProvider,
              );

          if (provider.isLoading &&
              provider.sessions.isEmpty) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (provider.sessions.isEmpty) {
            return const Center(
              child: Text(
                'No sessions found',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadSessions();
            },
            child: ListView.builder(
              padding:
                  const EdgeInsets.all(16),
              itemCount:
                  provider.sessions.length,
              itemBuilder: (
                context,
                index,
              ) {
                final session =
                    provider.sessions[index];

                final isActive =
                    session.status
                            .toUpperCase() ==
                        'ACTIVE';

                return Card(
                  margin:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),
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
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Text(
                              'Session ID: ${session.sessionId}',
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value ==
                                    'delete') {
                                  _confirmAndDeleteSession(
                                    session,
                                  );
                                } else if (value ==
                                    'close') {
                                  _closeSession(
                                    session,
                                  );
                                }
                              },
                              itemBuilder:
                                  (context) => [
                                if (isActive)
                                  const PopupMenuItem(
                                    value: 'close',
                                    child: Text(
                                      'Close Session',
                                    ),
                                  ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    'Delete Session',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Course: ${session.courseName}',
                        ),
                        Text(
                          'Status: ${session.status}',
                        ),
                        Text(
                          'Started: ${_formatDateTime(session.startedAt)}',
                        ),
                        Text(
                          'Closed: ${_formatDateTime(session.closedAt)}',
                        ),
                        if (isActive) ...[
                          const SizedBox(
                            height: 16,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child:
                                    ElevatedButton(
                                  onPressed:
                                      provider
                                              .isLoading
                                          ? null
                                          : () =>
                                              _closeSession(
                                            session,
                                          ),
                                  child:
                                      const Text(
                                    'Close Session',
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                child:
                                    ElevatedButton(
                                  onPressed:
                                      () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) =>
                                                SessionMonitorScreen(
                                          sessionId:
                                              session
                                                  .sessionId,
                                        ),
                                      ),
                                    );
                                  },
                                  child:
                                      const Text(
                                    'Monitor',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}