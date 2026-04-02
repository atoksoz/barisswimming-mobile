class GymexxtraProductModel {
  final int id;
  final String name;
  final double price;
  final bool isFirst;

  GymexxtraProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.isFirst = false,
  });

  factory GymexxtraProductModel.fromJson(Map<String, dynamic> json) {
    return GymexxtraProductModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['package_name']?.toString() ?? json['product_name']?.toString() ?? json['name']?.toString() ?? '',
      price: double.tryParse(json['total_price']?.toString() ?? json['price']?.toString() ?? '0') ?? 0.0,
      isFirst: json['is_first'] == true || json['is_first'] == 1,
    );
  }
}
