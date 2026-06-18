// mobile_app/lib/features/claims/data/claims_api_service.dart

import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';
import '../domain/claim.dart';
import '../domain/claim_statistics.dart';
import '../domain/claim_status.dart';

class ClaimAlreadyExistsException
    implements Exception {
  const ClaimAlreadyExistsException();

  @override
  String toString() {
    return 'Claim already exists';
  }
}

class InvalidClaimStateException
    implements Exception {
  const InvalidClaimStateException();

  @override
  String toString() {
    return 'Invalid claim state';
  }
}

class ClaimsApiService {
  final ApiClient _apiClient;

  ClaimsApiService(this._apiClient);

  Future<void> createClaim({
    required int attendanceId,
    required String reason,
  }) async {
    try {
      await _apiClient.dio.post(
        '/claims',
        data: {
          'attendance_id': attendanceId,
          'reason': reason,
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw const ClaimAlreadyExistsException();
      }

      rethrow;
    }
  }

  Future<List<Claim>> getMyClaims() async {
    final Response response =
        await _apiClient.dio.get(
      '/claims/mine',
    );

    final List<dynamic> data =
        response.data as List<dynamic>;

    return data
        .map(
          (item) => Claim.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<Claim> getClaim(
    int claimId,
  ) async {
    final Response response =
        await _apiClient.dio.get(
      '/claims/$claimId',
    );

    return Claim.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<ClaimStatistics>
      getStatistics() async {
    final Response response =
        await _apiClient.dio.get(
      '/claims/statistics',
    );

    return ClaimStatistics.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<List<Claim>> getFacultyClaims({
    String? statusFilter,
  }) async {
    final Response response =
        await _apiClient.dio.get(
      '/faculty/claims',
      queryParameters: {
        if (statusFilter != null)
          'status_filter': statusFilter,
      },
    );

    final List<dynamic> data =
        response.data as List<dynamic>;

    return data
        .map(
          (item) => Claim.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<int> getPendingClaimsCount() async {
    final claims =
        await getFacultyClaims(
      statusFilter: 'PENDING',
    );

    return claims.length;
  }

  Future<int> getResolvedClaimsCount() async {
    final claims = await getMyClaims();

    return claims.where(
      (claim) =>
          claim.status ==
              ClaimStatus.approved ||
          claim.status ==
              ClaimStatus.rejected,
    ).length;
  }

  Future<Claim> getFacultyClaim(
    int claimId,
  ) async {
    final Response response =
        await _apiClient.dio.get(
      '/faculty/claims/$claimId',
    );

    return Claim.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<void> approveClaim({
    required int claimId,
    required String resolutionReason,
  }) async {
    try {
      await _apiClient.dio.post(
        '/faculty/claims/$claimId/approve',
        data: {
          'resolution_reason':
              resolutionReason,
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw const InvalidClaimStateException();
      }

      rethrow;
    }
  }

  Future<void> rejectClaim({
    required int claimId,
    required String resolutionReason,
  }) async {
    try {
      await _apiClient.dio.post(
        '/faculty/claims/$claimId/reject',
        data: {
          'resolution_reason':
              resolutionReason,
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw const InvalidClaimStateException();
      }

      rethrow;
    }
  }
}