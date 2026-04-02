class ProductModel {
  final String categoryName;
  final String categoryUuid;
  final String productName;
  final double totalPrice;
  final String thumbImagePath;

  ProductModel({
    required this.categoryName,
    required this.categoryUuid,
    required this.productName,
    required this.totalPrice,
    required this.thumbImagePath,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      categoryName: json['category_name'] ?? '',
      categoryUuid: json['category_uuid'] ?? '',
      productName: json['product_name'] ?? '',
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      thumbImagePath: json['images'] != null &&
          (json['images'] as List).isNotEmpty &&
          json['images'][0]['thumb_image_path'] != null
          ? json['images'][0]['thumb_image_path']
          : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_name': categoryName,
      'category_uuid': categoryUuid,
      'product_name': productName,
      'total_price': totalPrice,
      'thumb_image_path': thumbImagePath,
    };
  }
}
