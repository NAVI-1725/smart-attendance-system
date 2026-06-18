// mobile_app/lib/features/claims/presentation/my_claims_screen.dart

import 'package:flutter/material.dart';

import '../../../core/services/api_client.dart';
import '../data/claims_api_service.dart';
import '../domain/claim.dart';
import 'claim_detail_screen.dart';

class MyClaimsScreen extends StatefulWidget {
  const MyClaimsScreen({
    super.key,
  });

  @override
  State<MyClaimsScreen> createState() =>
      _MyClaimsScreenState();
}

class _MyClaimsScreenState
    extends State<MyClaimsScreen> {
  late Future<List<Claim>> _claimsFuture;

  final ClaimsApiService _claimsApiService =
      ClaimsApiService(
        ApiClient(),
      );

  @override
  void initState() {
    super.initState();

    _claimsFuture =
        _claimsApiService.getMyClaims();
  }

  Future<void> _refresh() async {
    setState(() {
      _claimsFuture =
          _claimsApiService.getMyClaims();
    });

    await _claimsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Claims',
        ),
      ),
      body: FutureBuilder<List<Claim>>(
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

          final claims =
              snapshot.data ?? [];

          if (claims.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(
                    height: 300,
                    child: Center(
                      child: Text(
                        'No claims found',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
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
                      'Claim #${claim.id}',
                    ),
                    subtitle: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Text(
                          'Status: ${claim.status.name.toUpperCase()}',
                        ),
                        Text(
                          'Created: ${claim.createdAt.toLocal()}',
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          claim.reason,
                          maxLines: 2,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                        ),
                      ],
                    ),
                    trailing: const Icon(
                      Icons
                          .arrow_forward_ios,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ClaimDetailScreen(
                            claimId:
                                claim.id,
                          ),
                        ),
                      );
                    },
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