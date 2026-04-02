import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DeviceUuidStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _key = 'device_uuid';

  static Future<void> saveDeviceUuid(String uuid) async {
    await _storage.write(key: _key, value: uuid);
  }

  static Future<String?> getDeviceUuid() async {
    return _storage.read(key: _key);
  }

  static Future<void> deleteDeviceUuid() async {
    await _storage.delete(key: _key);
  }
}


