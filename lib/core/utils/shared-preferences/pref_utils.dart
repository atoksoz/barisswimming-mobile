import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/local_storage_constans.dart';

class PrefUtils {
  static const String _PREF_THEME = "app_theme";

  static Future<void> saveTheme(int themeIndex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(_PREF_THEME, themeIndex);
  }

  static Future<int> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_PREF_THEME) ?? 0;
  }

  static Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(LocalStorageConstants.tokenKey) ?? "";
  }

  static Future<String> getHamamSpaApiUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(LocalStorageConstants.hamamSpaApiUrlKey) ?? "";
  }

  static Future<String> getApplicationId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(LocalStorageConstants.applicationIdKey) ?? "";
  }
}
