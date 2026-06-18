// mobile_app/lib/features/claims/presentation/faculty_claim_detail_screen.dart

import 'package:flutter/material.dart';

import '../../faculty/presentation/attendance_evidence_screen.dart';
import '../data/claims_api_service.dart';
import '../domain/claim.dart';

class FacultyClaimDetailScreen
    extends StatefulWidget {
  final int claimId;
  final ClaimsApiService claimsApiService;

  const FacultyClaimDetailScreen({
    super.key,
    required this.claimId,
    required this.claimsApiService,
  });

  @override
  State<FacultyClaimDetailScreen>
      createState() =>
          _FacultyClaimDetailScreenState();
}

class _FacultyClaimDetailScreenState
    extends State<
        FacultyClaimDetailScreen> {
  late Future<Claim> _claimFuture;

  @override
  void initState() {
    super.initState();

    _claimFuture =
        widget.claimsApiService
            .getFacultyClaim(
      widget.claimId,
    );
  }

  Future<void> _reloadClaim() async {
    setState(() {
      _claimFuture =
          widget.claimsApiService
              .getFacultyClaim(
        widget.claimId,
      );
    });

    await _claimFuture;
  }

  Future<void> _approveClaim() async {
    final String? resolutionReason =
        await _showResolutionDialog(
      title: 'Approve Claim',
      actionLabel: 'Approve',
    );

    if (resolutionReason == null) {
      return;
    }

    try {
      await widget.claimsApiService
          .approveClaim(
        claimId: widget.claimId,
        resolutionReason:
            resolutionReason,
      );

      if (!mounted) {
        return;
      }

      await _reloadClaim();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Claim approved successfully',
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

  Future<void> _rejectClaim() async {
    final String? resolutionReason =
        await _showResolutionDialog(
      title: 'Reject Claim',
      actionLabel: 'Reject',
    );

    if (resolutionReason == null) {
      return;
    }

    try {
      await widget.claimsApiService
          .rejectClaim(
        claimId: widget.claimId,
        resolutionReason:
            resolutionReason,
      );

      if (!mounted) {
        return;
      }

      await _reloadClaim();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Claim rejected successfully',
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

  Future<String?> _showResolutionDialog({
    required String title,
    required String actionLabel,
  }) async {
    final controller =
        TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration:
                const InputDecoration(
              labelText:
                  'Resolution Reason',
              border:
                  OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final value =
                    controller.text.trim();

                if (value.isEmpty) {
                  return;
                }

                Navigator.pop(
                  context,
                  value,
                );
              },
              child: Text(
                actionLabel,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Claim Detail',
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
              child: Text(
                snapshot.error.toString(),
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

          return SingleChildScrollView(
            padding:
                const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                        Text(
                          'Claim ID: ${claim.id}',
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Student: ${claim.studentId}',
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Attendance: ${claim.attendanceId}',
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Course: N/A',
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Status: ${claim.status.name.toUpperCase()}',
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Reason: ${claim.reason}',
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Created: ${claim.createdAt}',
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Resolution Reason: ${claim.resolutionReason ?? 'N/A'}',
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Resolved At: ${claim.resolvedAt?.toString() ?? 'N/A'}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AttendanceEvidenceScreen(
                            attendanceId:
                                claim
                                    .attendanceId,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'View Evidence',
                    ),
                  ),
                ),
                if (claim.status.name ==
                    'pending') ...[
                  const SizedBox(
                    height: 12,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _approveClaim,
                      child: const Text(
                        'Approve',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _rejectClaim,
                      child: const Text(
                        'Reject',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}