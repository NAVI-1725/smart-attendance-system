// mobile_app/lib/features/claims/presentation/faculty_claims_screen.dart

import 'package:flutter/material.dart';

import '../../../core/services/api_client.dart';
import '../data/claims_api_service.dart';
import '../domain/claim.dart';
import 'faculty_claim_detail_screen.dart';

class FacultyClaimsScreen extends StatefulWidget {
  const FacultyClaimsScreen({
    super.key,
  });

  @override
  State<FacultyClaimsScreen> createState() =>
      _FacultyClaimsScreenState();
}

class _FacultyClaimsScreenState
    extends State<FacultyClaimsScreen> {
  final ClaimsApiService _claimsApiService =
      ClaimsApiService(
        ApiClient(),
      );

  late Future<List<Claim>> _claimsFuture;

  @override
  void initState() {
    super.initState();

    _claimsFuture =
        _claimsApiService.getFacultyClaims();
  }

  Future<void> _reloadClaims() async {
    final future =
        _claimsApiService.getFacultyClaims();

    setState(() {
      _claimsFuture = future;
    });

    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Faculty Claims',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _reloadClaims,
        child: FutureBuilder<List<Claim>>(
          future: _claimsFuture,
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
              return ListView(
                children: [
                  const SizedBox(
                    height: 200,
                  ),
                  Center(
                    child: Text(
                      snapshot.error.toString(),
                    ),
                  ),
                ],
              );
            }

            final claims =
                snapshot.data ?? [];

            if (claims.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(
                    height: 200,
                  ),
                  Center(
                    child: Text(
                      'No claims found',
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              itemCount: claims.length,
              itemBuilder: (
                context,
                index,
              ) {
                final claim =
                    claims[index];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(
                      'Student ${claim.studentId}',
                    ),
                    subtitle: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Text(
                          'Attendance ID: ${claim.attendanceId}',
                        ),
                        Text(
                          'Status: ${claim.status.name.toUpperCase()}',
                        ),
                        Text(
                          'Reason: ${claim.reason}',
                        ),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FacultyClaimDetailScreen(
                                claimId:
                                    claim.id,
                                claimsApiService:
                                    _claimsApiService,
                              ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}