/// Müzik okulu anasayfa — in-memory cache (60 sn TTL).
///
/// SharedPreferences'a yazmak gereksiz; uygulama oturumunda yeterli.
/// Serializasyon yok: ham Dart nesneleri tutulur.
class MuzikOkulumHomeCacheUtils {
  MuzikOkulumHomeCacheUtils._();

  static const Duration ttl = Duration(seconds: 60);

  static final Map<String, _CacheEntry<Object>> _store = {};

  /// Cache'den oku; TTL dolmuşsa `null` döner.
  static T? get<T extends Object>(String key) {
    final entry = _store[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.savedAt) > ttl) {
      _store.remove(key);
      return null;
    }
    final value = entry.value;
    return value is T ? value : null;
  }

  /// Cache'e yaz.
  static void set<T extends Object>(String key, T data) {
    _store[key] = _CacheEntry<Object>(value: data, savedAt: DateTime.now());
  }

  /// Belirli anahtarı sil.
  static void invalidate(String key) => _store.remove(key);

  /// Tüm cache'i temizle (pull-to-refresh vb.).
  static void invalidateAll() => _store.clear();
}

class _CacheEntry<T> {
  final T value;
  final DateTime savedAt;
  const _CacheEntry({required this.value, required this.savedAt});
}
