import 'package:intl/intl.dart';

class DateFormatUtils {
  static final _dateTime = DateFormat('dd/MM/yyyy HH:mm');
  static final _dateOnly = DateFormat('dd/MM/yyyy');
  static final _isoDate = DateFormat('yyyy-MM-dd');
  static final _sqlDateTime = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final _hm = DateFormat('HH:mm');
  static final _dayMonthYearDots = DateFormat('dd.MM.yyyy');

  /// Randevu `service-plans/calendar` — offsetsiz `YYYY-MM-DD HH:mm(:ss)`.
  static final RegExp _randevuCalendarNaiveDateTime = RegExp(
    r'^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})(?::(\d{2}))?$',
  );

  /// Naive string → cihaz **yerel** duvar saati ([formatSqlDateTime] ile uyumlu).
  static DateTime? _tryParseRandevuCalendarNaiveLocal(String raw) {
    final m = _randevuCalendarNaiveDateTime.firstMatch(raw.trim());
    if (m == null) return null;
    final sec = m.group(6);
    return DateTime(
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
      int.parse(m.group(4)!),
      int.parse(m.group(5)!),
      sec != null ? int.parse(sec) : 0,
    );
  }

  /// Takvim olayı başlangıcı (yerel gösterim / sıralama).
  static DateTime parseRandevuCalendarEventStartLocal(String raw) {
    final t = raw.trim();
    if (t.isEmpty) throw FormatException('Empty datetime', raw);
    final naive = _tryParseRandevuCalendarNaiveLocal(t);
    if (naive != null) return naive;
    return DateTime.parse(t).toLocal();
  }

  /// Bitiş: [durationHours] API’den geliyorsa `start + süre` (ISO `end` UTC ile yerel başlangıç uyuşmazlığını önler).
  static DateTime parseRandevuCalendarEventEndLocal(
    String startRaw,
    String endRaw, {
    double? durationHours,
  }) {
    final start = parseRandevuCalendarEventStartLocal(startRaw);
    if (durationHours != null && durationHours > 0) {
      final micros = (durationHours * Duration.microsecondsPerHour).round();
      return start.add(Duration(microseconds: micros));
    }
    final e = endRaw.trim();
    if (e.isEmpty) return start;
    return DateTime.parse(e).toLocal();
  }

  static String formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '';
    try {
      return _dateTime.format(DateTime.parse(dateTimeString));
    } catch (_) {
      return dateTimeString;
    }
  }

  static String formatDate(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '';
    try {
      return _dateOnly.format(DateTime.parse(dateTimeString));
    } catch (_) {
      return dateTimeString;
    }
  }

  /// Gün.ay.yıl (ör. Fitiz paket satırı `10.04.2026`).
  static String formatDayMonthYearDots(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '';
    try {
      return _dayMonthYearDots.format(DateTime.parse(dateTimeString.trim()).toLocal());
    } catch (_) {
      return '';
    }
  }

  /// d.m.Y (saat yok; gün/ay baştaki sıfırsız), yerel saat dilimi.
  /// API sorguları (`start` / `end`) için yerel takvim günü, `YYYY-MM-DD`.
  static String formatIsoDate(DateTime date) => _isoDate.format(date);

  /// `plan_datetime` (Randevu `service-plans` oluşturma) — yerel saat, `YYYY-MM-DD HH:mm:ss`.
  static String formatSqlDateTime(DateTime date) => _sqlDateTime.format(date);

  /// Randevu takvim — yerel `HH:mm - HH:mm`. [durationHours] verilirse bitiş süreyle hesaplanır.
  static String formatLocalHmRange(
    String startRaw,
    String endRaw, {
    double? durationHours,
  }) {
    try {
      final s = parseRandevuCalendarEventStartLocal(startRaw);
      final e = parseRandevuCalendarEventEndLocal(
        startRaw,
        endRaw,
        durationHours: durationHours,
      );
      return '${_hm.format(s)} - ${_hm.format(e)}';
    } catch (_) {
      return '';
    }
  }

  static String formatDateDayMonthYearDots(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '';
    try {
      final d = DateTime.parse(dateTimeString).toLocal();
      return '${d.day}.${d.month}.${d.year}';
    } catch (_) {
      return dateTimeString;
    }
  }
}
