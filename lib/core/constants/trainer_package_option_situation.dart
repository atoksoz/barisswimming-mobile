/// Randevu `GET …/package-options` → `options[].situation` (ör. api-system özeti).
abstract final class TrainerPackageOptionSituation {
  TrainerPackageOptionSituation._();

  static const String active = 'active';

  /// Yoklama / yakma için paket kullanılabilir mi (sunucu `active` beklenir).
  static bool allowsAttendanceActions(String situation) {
    return situation.trim().toLowerCase() == active;
  }
}
