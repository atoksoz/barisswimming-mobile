import 'package:e_sport_life/core/constants/near_expiry_package_constants.dart';

/// Aktif paket bitiş / kalan hak kuralları (donut kartı + liste filtresi).
class MemberPackageNearExpiryUtil {
  MemberPackageNearExpiryUtil._();

  static int _coerceInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.round();
    return int.tryParse(v.toString().trim()) ?? 0;
  }

  static int _pickInt(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      if (!m.containsKey(k)) continue;
      final v = m[k];
      if (v == null) continue;
      return _coerceInt(v);
    }
    return 0;
  }

  static int pickRemain(Map<String, dynamic> m) {
    return _pickInt(m, [
      'remain_quantity',
      'remainQuantity',
      'remaining_qty',
      'remainingQty',
    ]);
  }

  static int pickQuantity(Map<String, dynamic> m) {
    return _pickInt(m, [
      'quantity',
      'qty',
      'total_quantity',
      'totalQuantity',
    ]);
  }

  /// Hak sayılı pakette kalan 0 ise “aktif paketler” listesinde gösterilmez.
  static bool shouldOmitFromActivePackagesList(Map<String, dynamic> m) {
    return pickQuantity(m) > 0 && pickRemain(m) <= 0;
  }

  /// Bitiş günü yerel takvimde bugün veya sonrası.
  static bool isActiveByEndDate(Map<String, dynamic> m) {
    final d = calendarDaysUntilEnd(m);
    return d != null && d >= 0;
  }

  /// Bugünden bitiş gününe kadar tam gün farkı; bitmişse negatif; parse yoksa null.
  static int? calendarDaysUntilEnd(Map<String, dynamic> m) {
    final endDateStr = m['end_date']?.toString();
    if (endDateStr == null || endDateStr.isEmpty) return null;
    try {
      final end = DateTime.parse(endDateStr).toLocal();
      final now = DateTime.now();
      final startToday = DateTime(now.year, now.month, now.day);
      final endDay = DateTime(end.year, end.month, end.day);
      return endDay.difference(startToday).inDays;
    } catch (_) {
      return null;
    }
  }

  /// Aktif paket ve (kalan hak < 2 veya bitişe < 7 gün).
  ///
  /// Hak sayılı pakette kalan **0** ise yakında bitecek sayılmaz; liste ve donut uyarısında kart gösterilmez.
  static bool isNearExpiry(Map<String, dynamic> m) {
    if (!isActiveByEndDate(m)) return false;
    final q = pickQuantity(m);
    final rem = pickRemain(m);
    if (q > 0 && rem <= 0) return false;

    final days = calendarDaysUntilEnd(m);
    final dateUrgent = days != null &&
        days >= 0 &&
        days < NearExpiryPackageConstants.maxDaysUntilEndExclusive;
    if (q > 0) {
      final countUrgent =
          rem < NearExpiryPackageConstants.maxRemainExclusive;
      return dateUrgent || countUrgent;
    }
    return dateUrgent;
  }
}
