class MemberRegisterModel {
  final String id;
  final String uuid;
  final String memberType;
  final String startDate;
  final String endDate;
  final String quantity;
  final String registerDate;
  final String packageType;
  final String registeredUserId;
  final String registeredUsername;
  final String? frozen; // nullable
  final String? frozenStartDate;
  final String? frozenEndDate;

  MemberRegisterModel({
    required this.id,
    required this.uuid,
    required this.memberType,
    required this.startDate,
    required this.endDate,
    required this.quantity,
    required this.registerDate,
    required this.packageType,
    required this.registeredUserId,
    required this.registeredUsername,
    this.frozen,
    this.frozenStartDate,
    this.frozenEndDate,
  });

  factory MemberRegisterModel.fromJson(Map<String, dynamic> json) {
    return MemberRegisterModel(
      id: json['id'],
      uuid: json['uuid'],
      memberType: json['member_type'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      quantity: json['quantity'],
      registerDate: json['register_date'],
      packageType: json['package_type'],
      registeredUserId: json['registered_user_id'],
      registeredUsername: json['registered_username'],
      frozen: json['frozen'],
      frozenStartDate: json['frozen_start_date'],
      frozenEndDate: json['frozen_end_date'],
    );
  }
}
