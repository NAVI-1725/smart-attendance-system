import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyAuthToken = 'auth_token';
  static const String _keyDeviceId = 'device_id';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // -------- AUTH TOKEN --------

  String? getAuthToken() {
    return _prefs.getString(_keyAuthToken);
  }

  Future<void> saveAuthToken(String token) async {
    await _prefs.setString(_keyAuthToken, token);
  }

  Future<void> clearAuthToken() async {
    await _prefs.remove(_keyAuthToken);
  }

  // -------- DEVICE ID --------

  String? getDeviceId() {
    return _prefs.getString(_keyDeviceId);
  }

  Future<void> saveDeviceId(String deviceId) async {
    await _prefs.setString(_keyDeviceId, deviceId);
  }

  Future<void> clearDeviceId() async {
    await _prefs.remove(_keyDeviceId);
  }
}
