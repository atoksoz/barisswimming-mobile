/// `GET v2/me/invoices` — api-system [MemberInvoiceResource] çıktısı.
class MemberInvoiceModel {
  const MemberInvoiceModel({
    required this.id,
    this.memberId,
    this.memberRegisterId,
    this.recipientType,
    this.vkn,
    this.tckn,
    this.firstName,
    this.lastName,
    this.companyTitle,
    this.taxOffice,
    this.taxOfficeCode,
    this.email,
    this.phone,
    this.address,
    this.countryCode,
    this.city,
    this.district,
    this.postalCode,
    this.addressLine1,
    this.addressLine2,
    required this.isDefault,
    required this.isActive,
    this.note,
  });

  final int id;
  final int? memberId;
  final int? memberRegisterId;
  final String? recipientType;
  final String? vkn;
  final String? tckn;
  final String? firstName;
  final String? lastName;
  final String? companyTitle;
  final String? taxOffice;
  final String? taxOfficeCode;
  final String? email;
  final String? phone;
  final String? address;
  final String? countryCode;
  final String? city;
  final String? district;
  final String? postalCode;
  final String? addressLine1;
  final String? addressLine2;
  final bool isDefault;
  final bool isActive;
  final String? note;

  String get fullName {
    final parts = <String>[
      if (firstName != null && firstName!.trim().isNotEmpty) firstName!.trim(),
      if (lastName != null && lastName!.trim().isNotEmpty) lastName!.trim(),
    ];
    return parts.join(' ');
  }

  String get displayName {
    final name = fullName;
    if (name.isNotEmpty) return name;
    if (companyTitle != null && companyTitle!.trim().isNotEmpty) {
      return companyTitle!.trim();
    }
    return '—';
  }

  String get displayAddress {
    final parts = <String>[
      if (addressLine1 != null && addressLine1!.trim().isNotEmpty)
        addressLine1!.trim(),
      if (addressLine2 != null && addressLine2!.trim().isNotEmpty)
        addressLine2!.trim(),
      if (district != null && district!.trim().isNotEmpty) district!.trim(),
      if (city != null && city!.trim().isNotEmpty) city!.trim(),
    ];
    if (parts.isNotEmpty) return parts.join(', ');
    return address?.trim() ?? '';
  }

  factory MemberInvoiceModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return MemberInvoiceModel(
      id: parseInt(json['id']) ?? 0,
      memberId: parseInt(json['member_id']),
      memberRegisterId: parseInt(json['member_register_id']),
      recipientType: json['recipient_type']?.toString(),
      vkn: json['vkn']?.toString(),
      tckn: json['tckn']?.toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      companyTitle: json['company_title']?.toString(),
      taxOffice: json['tax_office']?.toString(),
      taxOfficeCode: json['tax_office_code']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      countryCode: json['country_code']?.toString(),
      city: json['city']?.toString(),
      district: json['district']?.toString(),
      postalCode: json['postal_code']?.toString(),
      addressLine1: json['address_line1']?.toString(),
      addressLine2: json['address_line2']?.toString(),
      isDefault: json['is_default'] == true,
      isActive: json['is_active'] == true,
      note: json['note']?.toString(),
    );
  }
}
