// mobile_app/lib/features/attendance/services/gps_service.dart

import 'package:geolocator/geolocator.dart';

class GpsService {
  Future<bool> isLocationEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  Future<bool> requestPermission() async {
    final enabled =
        await Geolocator.isLocationServiceEnabled();

    if (!enabled) {
      return false;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (
        permission == LocationPermission.denied ||
        permission ==
            LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<Position> getCurrentPosition() async {
    final enabled =
        await Geolocator.isLocationServiceEnabled();

    if (!enabled) {
      throw Exception(
        'Location services disabled',
      );
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission ==
        LocationPermission.denied) {
      throw Exception(
        'Location permission denied',
      );
    }

    if (permission ==
        LocationPermission.deniedForever) {
      throw Exception(
        'Enable location permission from settings',
      );
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy:
          LocationAccuracy.best,
    );
  }
}