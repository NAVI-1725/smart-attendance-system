// mobile_app/lib/features/claims/presentation/claim_detail_screen.dart

import 'package:flutter/material.dart';

import '../../../core/services/api_client.dart';
import '../data/claims_api_service.dart';
import '../domain/claim.dart';

class ClaimDetailScreen extends StatefulWidget {
  final int claimId;

  const ClaimDetailScreen({
    super.key,
    required this.claimId,
  });

  @override
  State<ClaimDetailScreen> createState() =>
      _ClaimDetailScreenState();
}

class _ClaimDetailScreenState
    extends State<ClaimDetailScreen> {
  late Future<Claim> _claimFuture;

  final ClaimsApiService _claimsApiService =
      ClaimsApiService(
        ApiClient(),
      );

  @override
  void initState() {
    super.initState();

    _claimFuture = _claimsApiService.getClaim(
      widget.claimId,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _claimFuture =
          _claimsApiService.getClaim(
        widget.claimId,
      );
    });

    await _claimFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Claim #${widget.claimId}',
        ),
      ),
      body: FutureBuilder<Claim>(
        future: _claimFuture,
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Text(
                  snapshot.error.toString(),
                  textAlign:
                      TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Claim not found',
              ),
            );
          }

          final claim = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding:
                  const EdgeInsets.all(16),
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
                          'Claim Status',
                          style: TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          claim.status.name
                              .toUpperCase(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
                          'Attendance ID',
                          style: TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          claim.attendanceId
                              .toString(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
                          'Reason',
                          style: TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          claim.reason,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
                          'Created Date',
                          style: TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          claim.createdAt
                              .toLocal()
                              .toString(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
                          'Resolution Reason',
                          style: TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          claim
                                  .resolutionReason
                                  ?.isNotEmpty ==
                              true
                              ? claim
                                  .resolutionReason!
                              : 'Not resolved yet',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
                          'Resolved Date',
                          style: TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          claim.resolvedAt !=
                                  null
                              ? claim
                                  .resolvedAt!
                                  .toLocal()
                                  .toString()
                              : 'Not resolved yet',
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