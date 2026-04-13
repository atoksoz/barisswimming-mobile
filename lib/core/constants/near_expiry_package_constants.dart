/// Paket kartı “bitmek üzere” uyarı eşikleri (aktif paketler).
class NearExpiryPackageConstants {
  NearExpiryPackageConstants._();

  /// `quantity > 0` iken kalan hak bu değerin **altındaysa** uyarı (örn. 0 veya 1).
  static const int maxRemainExclusive = 2;

  /// Bitişe kalan tam takvim günü bu değerin **altındaysa** uyarı (örn. 0…6).
  static const int maxDaysUntilEndExclusive = 7;
}
