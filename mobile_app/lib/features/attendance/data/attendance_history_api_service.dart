// mobile_app/lib/features/attendance/data/attendance_history_api_service.dart

import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';
import '../domain/attendance_history_item.dart';

class AttendanceHistoryApiService {
  final ApiClient _apiClient;

  AttendanceHistoryApiService(
    this._apiClient,
  );

  Future<List<AttendanceHistoryItem>>
      getHistory() async {
    try {
      final Response response =
          await _apiClient.dio.get(
        '/attendance/my-history',
      );

      final List<dynamic> data =
          response.data as List<dynamic>;

      return data
          .map(
            (item) =>
                AttendanceHistoryItem.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } on DioException catch (e) {
      print(
        'ATTENDANCE HISTORY ERROR: $e',
      );

      throw Exception(
        'Unable to load attendance history',
      );
    }
  }
}