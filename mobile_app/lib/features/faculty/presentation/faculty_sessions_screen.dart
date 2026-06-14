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
                        Text(
                          'Session ID: ${session.sessionId}',
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
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