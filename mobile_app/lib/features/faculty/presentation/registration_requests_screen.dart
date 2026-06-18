// mobile_app/lib/features/faculty/presentation/registration_requests_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_bootstrap.dart';
import '../../registration/data/registration_api_service.dart';
import '../../registration/presentation/registration_provider.dart';
import '../models/registration_request.dart';

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final _registrationProviderForScreen =
    ChangeNotifierProvider.autoDispose<RegistrationProvider>(
  (ref) => RegistrationProvider(
    RegistrationApiService(AppBootstrap.apiClient),
  ),
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class RegistrationRequestsScreen
    extends ConsumerStatefulWidget {
  final int sessionId;
  final String courseName;
  final String courseCode;

  const RegistrationRequestsScreen({
    super.key,
    required this.sessionId,
    required this.courseName,
    required this.courseCode,
  });

  @override
  ConsumerState<RegistrationRequestsScreen> createState() =>
      _RegistrationRequestsScreenState();
}

class _RegistrationRequestsScreenState
    extends ConsumerState<RegistrationRequestsScreen> {
  final Set<int> _actingOnIds = {};
  bool _bulkActionLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(_registrationProviderForScreen)
          .loadRequests(widget.sessionId);
    });
  }

  Future<void> _reload() async {
    await ref
        .read(_registrationProviderForScreen)
        .loadRequests(widget.sessionId);
  }

  Future<void> _approve(int requestId) async {
    setState(() => _actingOnIds.add(requestId));

    try {
      final success = await ref
          .read(_registrationProviderForScreen)
          .approveRequest(requestId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request approved'),
            backgroundColor: Colors.green,
          ),
        );
        await _reload();
      } else {
        final provider =
            ref.read(_registrationProviderForScreen);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ?? 'Failed to approve request',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _actingOnIds.remove(requestId));
      }
    }
  }

  Future<void> _reject(int requestId) async {
    setState(() => _actingOnIds.add(requestId));

    try {
      final success = await ref
          .read(_registrationProviderForScreen)
          .rejectRequest(requestId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request rejected'),
          ),
        );
        await _reload();
      } else {
        final provider =
            ref.read(_registrationProviderForScreen);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ?? 'Failed to reject request',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _actingOnIds.remove(requestId));
      }
    }
  }

  Future<void> _approveAll() async {
    setState(() => _bulkActionLoading = true);

    try {
      final success = await ref
          .read(_registrationProviderForScreen)
          .approveAll(widget.sessionId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All pending requests approved'),
            backgroundColor: Colors.green,
          ),
        );
        await _reload();
      } else {
        final provider =
            ref.read(_registrationProviderForScreen);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ?? 'Failed to approve all requests',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _bulkActionLoading = false);
      }
    }
  }

  Future<void> _rejectAll() async {
    setState(() => _bulkActionLoading = true);

    try {
      final success = await ref
          .read(_registrationProviderForScreen)
          .rejectAll(widget.sessionId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All pending requests rejected'),
          ),
        );
        await _reload();
      } else {
        final provider =
            ref.read(_registrationProviderForScreen);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ?? 'Failed to reject all requests',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _bulkActionLoading = false);
      }
    }
  }

  Color _statusColor(RegistrationRequestStatus s) {
    switch (s) {
      case RegistrationRequestStatus.approved:
        return Colors.green;
      case RegistrationRequestStatus.rejected:
        return Colors.red;
      case RegistrationRequestStatus.pending:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(
      _registrationProviderForScreen,
    );

    final pendingCount = provider.requests
        .where((r) => r.status.isPending)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registration Requests',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              '${widget.courseCode} — ${widget.courseName}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: provider.isLoading && provider.requests.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (pendingCount > 0) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _bulkActionLoading
                                ? null
                                : _approveAll,
                            icon: const Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                            ),
                            label: Text(
                              'Approve All ($pendingCount)',
                              style: const TextStyle(
                                color: Colors.green,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _bulkActionLoading
                                ? null
                                : _rejectAll,
                            icon: const Icon(
                              Icons.cancel_outlined,
                              color: Colors.red,
                            ),
                            label: Text(
                              'Reject All ($pendingCount)',
                              style: const TextStyle(
                                color: Colors.red,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                ],
                Expanded(
                  child: provider.requests.isEmpty
                      ? const Center(
                          child: Text(
                            'No registration requests yet',
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _reload,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: provider.requests.length,
                            itemBuilder: (context, index) {
                              final req =
                                  provider.requests[index];
                              final isActing =
                                  _actingOnIds.contains(req.id);

                              return Card(
                                margin: const EdgeInsets.only(
                                  bottom: 12,
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              req.studentName,
                                              style: Theme.of(
                                                context,
                                              )
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                          ),
                                          Container(
                                            padding:
                                                const EdgeInsets
                                                    .symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration:
                                                BoxDecoration(
                                              color: _statusColor(
                                                req.status,
                                              ).withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(4),
                                            ),
                                            child: Text(
                                              req.status.label,
                                              style: TextStyle(
                                                color: _statusColor(
                                                  req.status,
                                                ),
                                                fontSize: 12,
                                                fontWeight:
                                                    FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (req.status.isPending) ...[
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: isActing ||
                                                        _bulkActionLoading
                                                    ? null
                                                    : () =>
                                                        _approve(
                                                          req.id,
                                                        ),
                                                style: ElevatedButton
                                                    .styleFrom(
                                                  backgroundColor:
                                                      Colors.green,
                                                  foregroundColor:
                                                      Colors.white,
                                                ),
                                                child: isActing
                                                    ? const SizedBox(
                                                        width: 16,
                                                        height: 16,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth:
                                                              2,
                                                          color: Colors
                                                              .white,
                                                        ),
                                                      )
                                                    : const Text(
                                                        'Approve',
                                                      ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 12,
                                            ),
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: isActing ||
                                                        _bulkActionLoading
                                                    ? null
                                                    : () =>
                                                        _reject(
                                                          req.id,
                                                        ),
                                                style: OutlinedButton
                                                    .styleFrom(
                                                  foregroundColor:
                                                      Colors.red,
                                                  side:
                                                      const BorderSide(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Reject',
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
                        ),
                ),
              ],
            ),
    );
  }
}