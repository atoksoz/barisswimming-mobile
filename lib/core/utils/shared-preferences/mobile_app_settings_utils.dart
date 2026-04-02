import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/mobile-app-settings/mobile_app_settings.dart';

const String mobileAppSettingsKey = 'mobile_app_settings';

Future<void> saveMobileAppSettingsToSharedPref(
    MobileAppSettings settings) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
      mobileAppSettingsKey, json.encode(settings.toJson()));
}

Future<MobileAppSettings?> loadMobileAppSettingsFromSharedPref() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(mobileAppSettingsKey);
  if (raw == null) {
    return null;
  }
  final jsonMap = json.decode(raw) as Map<String, dynamic>;
  return MobileAppSettings.fromJson(jsonMap);
}

Future<void> clearMobileAppSettingsFromSharedPref() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(mobileAppSettingsKey);
}


