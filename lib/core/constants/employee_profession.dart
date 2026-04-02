import 'package:e_sport_life/core/l10n/app_labels.dart';

class EmployeeProfession {
  EmployeeProfession._();

  static String getLabel(String? key) {
    if (key == null || key.trim().isEmpty) return '';
    final trimmed = key.trim();
    return AppLabels.current.professionLabels[trimmed] ?? trimmed;
  }

  /// Virgülle ayrılmış birden fazla meslek key'ini localize label'lara çevirir.
  static String getLabels(String? keys) {
    if (keys == null || keys.trim().isEmpty) return '';
    return keys
        .split(',')
        .map((k) => getLabel(k.trim()))
        .where((label) => label.isNotEmpty)
        .join(', ');
  }
}
