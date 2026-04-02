class GymexxtraOrderModel {
  final String orderNo;
  final String date;
  final String productName;
  final int quantity;
  final double listPrice;
  final double discount;
  final double discountedPrice;
  final int installmentCount;
  final double installmentPrice;
  final double totalPrice;
  final String status;
  final String statusLabel;
  final String tenantName;
  final bool isFirst;

  GymexxtraOrderModel({
    required this.orderNo,
    required this.date,
    required this.productName,
    required this.quantity,
    required this.listPrice,
    required this.discount,
    required this.discountedPrice,
    required this.installmentCount,
    required this.installmentPrice,
    required this.totalPrice,
    required this.status,
    required this.statusLabel,
    required this.tenantName,
    required this.isFirst,
  });

  factory GymexxtraOrderModel.fromJson(Map<String, dynamic> json) {
    double totalAmount = double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0;
    double discountAmount = double.tryParse(json['discount_amount']?.toString() ?? '0') ?? 0.0;
    double discounted = totalAmount - discountAmount;
    double finalAmount = double.tryParse(json['final_amount']?.toString() ?? '0') ?? discounted;
    int installments = int.tryParse(json['installment_count']?.toString() ?? '1') ?? 1;
    if (installments < 1) installments = 1;
    double instPrice = finalAmount / installments;

    return GymexxtraOrderModel(
      orderNo: json['order_number']?.toString() ?? json['order_no']?.toString() ?? '',
      date: json['created_at']?.toString() ?? json['date']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      quantity: json['quantity'] ?? 1,
      listPrice: totalAmount,
      discount: discountAmount,
      discountedPrice: discounted,
      installmentCount: installments,
      installmentPrice: instPrice,
      totalPrice: finalAmount,
      status: json['status']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
      tenantName: json['tenant_name']?.toString() ?? '',
      isFirst: json['is_first'] == true || json['is_first'] == 1,
    );
  }
}
