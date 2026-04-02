import 'package:e_sport_life/core/enums/supported_locale.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCacheUtils {
  static const String _key = 'app_locale';

  static Future<void> save(SupportedLocale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.code);
  }

  static Future<SupportedLocale> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code == null) return SupportedLocale.tr;
    return SupportedLocale.fromCode(code);
  }
}
