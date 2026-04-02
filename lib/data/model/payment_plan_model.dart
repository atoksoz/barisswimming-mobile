class PaymentPlanModel {
  final String memberType;
  final double paymentPrice;
  final String paymentDate;
  final String? explanation;

  PaymentPlanModel({
    required this.memberType,
    required this.paymentPrice,
    required this.paymentDate,
    this.explanation,
  });

  factory PaymentPlanModel.fromJson(Map<String, dynamic> json) {
    return PaymentPlanModel(
      memberType: json['member_type']?.toString().trim() ?? '',
      paymentPrice:
          double.tryParse(json['payment_price']?.toString() ?? '') ?? 0.0,
      paymentDate:
          json['payment_date']?.toString().trim().replaceAll("-", "/") ?? '',
      explanation: json['explanation']?.toString(), // explanation null olabilir
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_type': memberType,
      'payment_price': paymentPrice.toStringAsFixed(2),
      'payment_date': paymentDate,
      'explanation': explanation,
    };
  }
}
