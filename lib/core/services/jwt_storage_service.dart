import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class JwtStorageService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'jwt_token';

  /// JWT'yi kaydeder
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _key, value: token);
  }

  /// JWT'yi okur
  static Future<String?> getToken() async {
    return await _storage.read(key: _key);
  }

  /// JWT'yi siler
  static Future<void> deleteToken() async {
    await _storage.delete(key: _key);
  }

  /// JWT var mı kontrol eder
  static Future<bool> hasToken() async {
    final token = await _storage.read(key: _key);
    return token != null && token.isNotEmpty;
  }
}
