class OrderHistoryModel {
  final String product_name;
  final String price;
  final String created_at;
  final String payment_type;
  final String image;
  final int? paid;

  OrderHistoryModel({
    required this.product_name,
    required this.price,
    required this.created_at,
    required this.payment_type,
    required this.image,
    required this.paid,
  });

  factory OrderHistoryModel.fromJson(Map<String, dynamic> json) {
    return OrderHistoryModel(
      product_name: json["product_name"],
      price: json['price'],
      created_at: json['created_at'],
      payment_type: json['payment_type'],
      image: json['image'],
      paid: json['paid'] is int
          ? json['paid']
          : int.tryParse(json['paid']?.toString() ?? '0'),
    );
  }
}
