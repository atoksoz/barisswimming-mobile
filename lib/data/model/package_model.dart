import 'member_register_file_model.dart';

class PackageModel {
  final String member_type;
  final String subscription_price;
  final String start_date;
  final String end_date;
  final String register_date;
  final String remain_quantity;
  final String is_frozen;
  final String contract_id;
  final String price;
  final String discount;
  final String quantity;
  final int is_expired;
  final String? employee_id;
  final String? member_register_id;
  final String? product_id;
  final List<MemberRegisterFileModel> files;

  PackageModel(
      {required this.member_type,
      required this.subscription_price,
      required this.price,
      required this.discount,
      required this.start_date,
      required this.end_date,
      required this.register_date,
      required this.remain_quantity,
      required this.is_frozen,
      required this.contract_id,
      required this.quantity,
      required this.is_expired,
      this.employee_id,
      this.member_register_id,
      this.product_id,
      required this.files});

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    List<MemberRegisterFileModel> filesList = [];
    if (json['files'] != null && json['files'] is List) {
      filesList = (json['files'] as List)
          .map((fileJson) => MemberRegisterFileModel.fromJson(fileJson))
          .toList();
    }

    return PackageModel(
      member_type: json["member_type"] ?? '',
      subscription_price: json['subscription_price'] ?? '',
      start_date: json['start_date'] ?? '',
      end_date: json["end_date"] ?? '',
      register_date: json['register_date'] ?? '',
      remain_quantity: json['remain_quantity'] ?? '',
      quantity: json['quantity'] ?? '',
      is_frozen: json['is_frozen'] ?? '',
      contract_id: (json['contract_id'] == null || json['contract_id'] == "0")
          ? ''
          : json['contract_id'].toString(),
      price: json['price'] ?? '',
      discount: json['discount'] ?? '',
      is_expired: int.tryParse(json['is_expired']?.toString() ?? '') ?? 0,
      employee_id: json['employee_id']?.toString(),
      member_register_id: json['member_register_id']?.toString(),
      product_id: json['product_id']?.toString(),
      files: filesList,
    );
  }
}
