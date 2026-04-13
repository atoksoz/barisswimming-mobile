import 'package:e_sport_life/core/l10n/app_labels.dart';

/// Planlı ödeme vadesinin bugüne göre göreli etiketi (takvim günü).
class PaymentReminderDueLabelUtil {
  PaymentReminderDueLabelUtil._();

  static String relativeDueText(
    AppLabels labels,
    DateTime paymentDateLocal,
  ) {
    final now = DateTime.now();
    final startToday = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(
      paymentDateLocal.year,
      paymentDateLocal.month,
      paymentDateLocal.day,
    );
    final days = dueDay.difference(startToday).inDays;
    if (days <= 0) return labels.homeReminderPaymentDueToday;
    if (days == 1) return labels.homeReminderPaymentDueTomorrow;
    return labels.homeReminderPaymentDueInDays(days);
  }
}
