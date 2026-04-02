import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const String seenAnnouncementIdsKey = 'seen_announcement_ids';
const String lastCheckedAnnouncementIdKey = 'last_checked_announcement_id';

/// Görülen duyuru ID'lerini kaydet
Future<void> saveSeenAnnouncementIds(List<int> ids) async {
  final prefs = await SharedPreferences.getInstance();
  final idsString = ids.map((id) => id.toString()).toList();
  await prefs.setStringList(seenAnnouncementIdsKey, idsString);
}

/// Görülen duyuru ID'lerini yükle
Future<List<int>> loadSeenAnnouncementIds() async {
  final prefs = await SharedPreferences.getInstance();
  final idsString = prefs.getStringList(seenAnnouncementIdsKey);
  if (idsString == null) return [];
  return idsString.map((id) => int.tryParse(id) ?? 0).where((id) => id > 0).toList();
}

/// Belirli bir duyuru ID'sini görüldü olarak işaretle
Future<void> markAnnouncementAsSeen(int announcementId) async {
  final seenIds = await loadSeenAnnouncementIds();
  if (!seenIds.contains(announcementId)) {
    seenIds.add(announcementId);
    await saveSeenAnnouncementIds(seenIds);
  }
}

/// Bir duyurunun görülüp görülmediğini kontrol et
Future<bool> isAnnouncementSeen(int announcementId) async {
  final seenIds = await loadSeenAnnouncementIds();
  return seenIds.contains(announcementId);
}

/// Son kontrol edilen duyuru ID'sini kaydet
Future<void> saveLastCheckedAnnouncementId(int announcementId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(lastCheckedAnnouncementIdKey, announcementId);
}

/// Son kontrol edilen duyuru ID'sini yükle
Future<int?> loadLastCheckedAnnouncementId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(lastCheckedAnnouncementIdKey);
}

/// Tüm announcement cache'ini temizle
Future<void> clearAnnouncementCache() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(seenAnnouncementIdsKey);
  await prefs.remove(lastCheckedAnnouncementIdKey);
}

