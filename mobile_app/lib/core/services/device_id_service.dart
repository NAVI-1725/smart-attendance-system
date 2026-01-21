import 'package:uuid/uuid.dart';
import 'local_storage_service.dart';

class DeviceIdService {
  static const _uuid = Uuid();

  final LocalStorageService _localStorage;

  DeviceIdService(this._localStorage);

  Future<String> getOrCreateDeviceId() async {
    final existingId = _localStorage.getDeviceId();

    if (existingId != null && existingId.isNotEmpty) {
      return existingId;
    }

    final newDeviceId = _uuid.v4();
    await _localStorage.saveDeviceId(newDeviceId);

    return newDeviceId;
  }
}
