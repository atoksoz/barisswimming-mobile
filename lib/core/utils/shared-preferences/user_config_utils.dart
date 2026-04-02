import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/user-config/user_config.dart';

String userConfigKey = "user_config";

Future<void> saveUserConfigToSharedPref(UserConfig config) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(userConfigKey, json.encode(config.toJson()));
}

Future<UserConfig?> loadUserConfigFromSharedPref() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(userConfigKey);
  if (raw != null) {
    final jsonMap = json.decode(raw);
    return UserConfig.fromJson(jsonMap);
  }
  return null;
}

Future<void> clear() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(userConfigKey);
}
