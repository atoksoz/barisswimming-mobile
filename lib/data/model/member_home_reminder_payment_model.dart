/// Anasayfa hatırlatıcı şeridi — yakın vadeli planlı ödeme (gecikenler özet kartında).
class MemberHomeReminderPaymentModel {
  final int? id;
  final double amount;
  final DateTime paymentDateLocal;
  final String explanation;

  const MemberHomeReminderPaymentModel({
    required this.id,
    required this.amount,
    required this.paymentDateLocal,
    required this.explanation,
  });
}
