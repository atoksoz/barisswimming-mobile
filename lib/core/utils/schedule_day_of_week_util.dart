/// Randevu `my-schedule` yanıtındaki [day_of_week] için güvenli çözümleme.
/// ISO-8601: 1 = Pazartesi … 7 = Pazar (Dart [DateTime.weekday] ile uyumlu).
/// Bazı kaynaklarda Pazar `0` (JS tarzı) gelebilir → 7 sayılır.
class ScheduleDayOfWeekUtil {
  ScheduleDayOfWeekUtil._();

  static int? parseToIsoWeekday(dynamic raw) {
    if (raw == null) return null;
    int? v;
    if (raw is int) {
      v = raw;
    } else if (raw is num) {
      v = raw.toInt();
    } else {
      v = int.tryParse(raw.toString().trim());
    }
    if (v == null) return null;
    if (v == 0) return 7;
    if (v >= 1 && v <= 7) return v;
    return null;
  }
}
