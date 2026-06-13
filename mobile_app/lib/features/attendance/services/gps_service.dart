// mobile_app/lib/features/attendance/services/gps_service.dart

import 'package:geolocator/geolocator.dart';

class LocationDisabledException
    implements Exception {
  const LocationDisabledException();
}

class LocationPermissionDeniedException
    implements Exception {
  const LocationPermissionDeniedException();
}

class LocationPermissionForeverDeniedException
    implements Exception {
  const LocationPermissionForeverDeniedException();
}

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
      throw const LocationDisabledException();
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission ==
        LocationPermission.denied) {
      throw const LocationPermissionDeniedException();
    }

    if (permission ==
        LocationPermission.deniedForever) {
      throw const LocationPermissionForeverDeniedException();
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy:
          LocationAccuracy.best,
    );
  }
}