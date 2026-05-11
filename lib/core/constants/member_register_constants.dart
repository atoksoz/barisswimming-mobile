/// Hamam `member_register` API alanlarıyla uyumlu sabitler (mobil hamam spa tarafı).
abstract final class MemberRegisterConstants {
  MemberRegisterConstants._();

  /// `package_type` — fitness / salon üyeliği satırı.
  static const String packageTypeGym = 'GYM';

  /// `start_date`, `end_date`, dondurma tarihleri için kullanılan biçim.
  static const String apiDatePatternDdMmYyyy = 'dd-MM-yyyy';

  /// Üye kaydı dosyası `created_at` API biçimi.
  static const String apiDateTimePatternYyyyMmDdHhMmSs =
      'yyyy-MM-dd HH:mm:ss';

  /// Dosya satırında gösterilen tarih/saat biçimi.
  static const String displayDateTimePatternDdMmYyyyHhMm =
      'dd/MM/yyyy HH:mm';

  /// Grafik yüzdesi için üst sınır (oran hesabı).
  static const int chartRatePercentMax = 100;
}
