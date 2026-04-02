import 'dart:convert';

import 'package:e_sport_life/data/model/is_done_movement_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

String getCacheKeyForDay(String day) => 'done_movements_$day';

Future<void> saveMovementsToCache(
    String day, List<IsDoneMovementModel> movements) async {
  final prefs = await SharedPreferences.getInstance();
  final key = getCacheKeyForDay(day);
  final jsonList = movements.map((e) => e.toJson()).toList();
  await prefs.setString(key, json.encode(jsonList));
}

Future<List<IsDoneMovementModel>> loadMovementsFromCache(String day) async {
  final prefs = await SharedPreferences.getInstance();
  final key = getCacheKeyForDay(day);
  final raw = prefs.getString(key);
  if (raw != null) {
    final jsonList = json.decode(raw) as List;
    return jsonList.map((e) => IsDoneMovementModel.fromJson(e)).toList();
  }
  return [];
}

Future<void> clearMovementsForDay(String day) async {
  final prefs = await SharedPreferences.getInstance();
  final key = getCacheKeyForDay(day);
  await prefs.remove(key);
}
