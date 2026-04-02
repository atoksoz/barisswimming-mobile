import 'package:shared_preferences/shared_preferences.dart';

const String _gymFrozenStatusKey = 'is_gym_frozen';
const String _gymRemainDaysKey = 'gym_remain_days';

Future<void> saveGymFrozenStatusToCache(bool isFrozen) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_gymFrozenStatusKey, isFrozen);
}

Future<void> saveGymRemainDaysToCache(double remainDays) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setDouble(_gymRemainDaysKey, remainDays);
}

Future<bool> loadGymFrozenStatusFromCache() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_gymFrozenStatusKey) ?? false;
}

Future<double> loadGymRemainDaysFromCache() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getDouble(_gymRemainDaysKey) ?? 0.0;
}

Future<void> clearGymFrozenStatusFromCache() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_gymFrozenStatusKey);
  await prefs.remove(_gymRemainDaysKey);
}
