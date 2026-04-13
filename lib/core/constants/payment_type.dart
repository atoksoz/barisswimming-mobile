import 'package:e_sport_life/core/l10n/app_labels.dart';

class PaymentType {
  PaymentType._();

  static String getLabel(String? key) {
    if (key == null || key.trim().isEmpty) return '';
    final trimmed = key.trim();
    return AppLabels.current.paymentTypeLabels[trimmed] ?? trimmed;
  }
}
