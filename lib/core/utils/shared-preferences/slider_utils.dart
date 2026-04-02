import 'package:shared_preferences/shared_preferences.dart';

const String _sliderItemsKey = 'slider_items';
const String _sliderEndTimeKey = 'slider_end_time';
const String _sliderWaitTimeKey = 'slider_wait_time';

Future<List<String>?> getSliderScreenItems() async {
  final prefs = await SharedPreferences.getInstance();
  final items = prefs.getStringList(_sliderItemsKey);
  final endTimeStr = prefs.getString(_sliderEndTimeKey);

  if (isSliderScreenSliderValid(endTimeStr) == false) {
    await clearSliderScreenSliderItems();
  }

  if (items != null && isSliderScreenSliderValid(endTimeStr)) {
    return items;
  }
  return null;
}

Future<int> getSliderWaitTime() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(_sliderWaitTimeKey) ?? 10; // Varsayılan 10 saniye
}

Future<void> saveSliderScreenItems(List<String> items, String endTime, int waitTime) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(_sliderItemsKey, items);
  await prefs.setString(_sliderEndTimeKey, endTime);
  await prefs.setInt(_sliderWaitTimeKey, waitTime);
}

Future<void> clearSliderScreenSliderItems() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_sliderItemsKey);
  await prefs.remove(_sliderEndTimeKey);
  await prefs.remove(_sliderWaitTimeKey);
}

bool isSliderScreenSliderValid(String? endTimeStr) {
  if (endTimeStr == null) return true;
  final endTime = DateTime.tryParse(endTimeStr);
  if (endTime == null) return true;
  return endTime.isAfter(DateTime.now());
}
