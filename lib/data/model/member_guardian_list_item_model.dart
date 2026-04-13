/// `GET v2/me/guardians` — api-system [MemberGuardianResource] / `enrichGuardianWithIam` çıktısı.
class MemberGuardianListItemModel {
  const MemberGuardianListItemModel({
    this.id,
    this.guardianMemberId,
    required this.name,
    required this.phone,
    required this.gender,
    this.relation,
    this.note,
    required this.isPrimary,
    this.email,
    this.secondaryPhone,
    this.professionGroup,
    this.province,
    this.district,
    this.address,
  });

  final int? id;
  final int? guardianMemberId;
  final String name;
  final String phone;
  final int gender;
  final String? relation;
  final String? note;
  final bool isPrimary;
  final String? email;
  final String? secondaryPhone;
  final String? professionGroup;
  final String? province;
  final String? district;
  final String? address;

  bool get hasDetailSection {
    return phone.trim().isNotEmpty ||
        (secondaryPhone?.trim().isNotEmpty ?? false) ||
        (email?.trim().isNotEmpty ?? false) ||
        (professionGroup?.trim().isNotEmpty ?? false) ||
        (province?.trim().isNotEmpty ?? false) ||
        (district?.trim().isNotEmpty ?? false) ||
        (address?.trim().isNotEmpty ?? false) ||
        (note?.trim().isNotEmpty ?? false);
  }

  factory MemberGuardianListItemModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return MemberGuardianListItemModel(
      id: parseInt(json['id']),
      guardianMemberId: parseInt(json['guardian_member_id']),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      gender: parseInt(json['gender']) ?? 0,
      relation: json['relation']?.toString(),
      note: json['note']?.toString(),
      isPrimary: json['is_primary'] == true,
      email: json['email']?.toString(),
      secondaryPhone: json['secondary_phone']?.toString(),
      professionGroup: json['profession_group']?.toString(),
      province: json['province']?.toString(),
      district: json['district']?.toString(),
      address: json['address']?.toString(),
    );
  }
}
