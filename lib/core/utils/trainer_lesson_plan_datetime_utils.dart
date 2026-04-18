/// Haftalık planda seçilen [weekday] + saat için bir sonraki `plan_datetime` anı.
class TrainerLessonPlanDatetimeUtils {
  TrainerLessonPlanDatetimeUtils._();

  /// [weekday]: `DateTime.monday` … `DateTime.sunday` (1–7).
  static DateTime nextDateTimeForWeekday({
    required int weekday,
    required int hour,
    required int minute,
  }) {
    final now = DateTime.now();
    for (var add = 0; add <= 21; add++) {
      final d = DateTime(now.year, now.month, now.day).add(Duration(days: add));
      if (d.weekday != weekday) continue;
      final candidate = DateTime(d.year, d.month, d.day, hour, minute);
      if (candidate.isAfter(now)) return candidate;
    }
    return DateTime(now.year, now.month, now.day, hour, minute)
        .add(const Duration(days: 7));
  }
}
