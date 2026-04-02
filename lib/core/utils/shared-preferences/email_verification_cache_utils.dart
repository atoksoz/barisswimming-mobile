import 'package:shared_preferences/shared_preferences.dart';

class EmailVerificationCacheUtils {
  static const String _key = 'email_verification_requested';
  static const String _verifiedKey = 'email_verified';

  static Future<void> setVerificationRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  static Future<bool> isVerificationRequested() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> clearVerificationRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> setEmailVerified() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_verifiedKey, true);
  }

  static Future<bool> isEmailVerified() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_verifiedKey) ?? false;
  }

  static Future<void> clearEmailVerified() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_verifiedKey);
  }
}

