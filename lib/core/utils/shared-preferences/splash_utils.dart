import 'package:shared_preferences/shared_preferences.dart';

const String _sliderItemsKey = 'splash_items';
const String _sliderEndTimeKey = 'splash_end_time';

Future<List<String>?> getSplashScreenSliderItems() async {
  final prefs = await SharedPreferences.getInstance();
  final items = prefs.getStringList(_sliderItemsKey);
  final endTimeStr = prefs.getString(_sliderEndTimeKey);

  if (isSplashScreenSliderValid(endTimeStr) == false) {
    await clearSplashScreenItems();
  }

  if (items != null && isSplashScreenSliderValid(endTimeStr)) {
    return items;
  }
  return null;
}

Future<void> saveSplashScreenSliderItems(
    List<String> items, String endTime) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(_sliderItemsKey, items);
  await prefs.setString(_sliderEndTimeKey, endTime);
}

Future<void> clearSplashScreenItems() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_sliderItemsKey);
  await prefs.remove(_sliderEndTimeKey);
}

bool isSplashScreenSliderValid(String? endTimeStr) {
  if (endTimeStr == null) return true;
  final endTime = DateTime.tryParse(endTimeStr);
  if (endTime == null) return true;
  return endTime.isAfter(DateTime.now());
}
