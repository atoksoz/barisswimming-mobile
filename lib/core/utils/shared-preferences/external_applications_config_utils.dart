import 'dart:convert';

import 'package:e_sport_life/config/external-applications-config/external_applications_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String externalApplicationConfigKey = 'external_applications_config';

Future<void> saveExternalApplicationsConfigToSharedPref(
    ExternalApplicationsConfig config) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
      externalApplicationConfigKey, json.encode(config.toJson()));
}

Future<ExternalApplicationsConfig?>
    loadExternalApplicationsConfigFromSharedPref() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(externalApplicationConfigKey);
  if (raw != null) {
    final jsonMap = json.decode(raw);
    return ExternalApplicationsConfig.fromJson(jsonMap);
  }
  return null;
}

Future<void> externalApplicationsConfigClearFromSharedPref() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(externalApplicationConfigKey);
}
