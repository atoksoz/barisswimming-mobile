import 'package:e_sport_life/core/constants/employee_profession.dart';

/// Uzmanlık / meslek kodlarını (`key`) güncel dil etiketine göre sıralamak için.
abstract final class ProfessionKeysSortUtils {
  ProfessionKeysSortUtils._();

  static String displayLabel(
    String key,
    Map<String, String> professionLabels,
  ) {
    return professionLabels[key] ?? EmployeeProfession.getLabel(key);
  }

  /// Büyük/küçük harf duyarsız A–Z (Unicode `compareTo` sırası).
  static int compareByLocalizedLabel(
    String keyA,
    String keyB,
    Map<String, String> professionLabels,
  ) {
    final la = displayLabel(keyA, professionLabels);
    final lb = displayLabel(keyB, professionLabels);
    return la.toLowerCase().compareTo(lb.toLowerCase());
  }

  /// [keys] kopyalanır; orijinal koleksiyon değişmez.
  static List<String> sortedKeys(
    Iterable<String> keys,
    Map<String, String> professionLabels,
  ) {
    final list = List<String>.from(keys);
    list.sort((a, b) => compareByLocalizedLabel(a, b, professionLabels));
    return list;
  }
}
