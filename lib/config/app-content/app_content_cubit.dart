import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_content.dart';

class AppContentCubit extends Cubit<AppContent?> {
  AppContentCubit() : super(null);

  static const _cacheKey = 'app_content';

  Future<AppContent?> loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final content = AppContent.fromJson(json);
      emit(content);
      return content;
    } catch (_) {
      return null;
    }
  }

  Future<void> updateContent(AppContent content) async {
    emit(content);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(content.toJson()));
  }

  Future<void> clearContent() async {
    emit(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}
