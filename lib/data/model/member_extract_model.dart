class MemberExtract {
  final String member_type;
  final String subscription_price;
  final String payment_price;
  final String register_date;
  final String payment_date;
  final String payment_type;
  final String package_type;

  MemberExtract({
    required this.member_type,
    required this.subscription_price,
    required this.payment_price,
    required this.register_date,
    required this.payment_date,
    required this.payment_type,
    required this.package_type,
  });

  factory MemberExtract.fromJson(Map<String, dynamic> json) {
    return MemberExtract(
        member_type: json["member_type"],
        subscription_price: json['subscription_price'],
        payment_price: json['payment_price'],
        register_date: json["register_date"],
        payment_date: json['payment_date'],
        payment_type: json['payment_type'],
        package_type: json['package_type']);
  }
}
