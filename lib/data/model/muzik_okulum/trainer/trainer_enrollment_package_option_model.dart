/// Randevu `GET …/package-options` çıktısı (`options[]` satırı).
class TrainerEnrollmentPackageOptionModel {
  final int memberRegisterId;
  final int productPackageId;
  final String name;
  final int? remainingQty;
  final String? startDate;
  final String? endDate;
  final String situation;
  final bool isSelected;

  const TrainerEnrollmentPackageOptionModel({
    required this.memberRegisterId,
    required this.productPackageId,
    required this.name,
    this.remainingQty,
    this.startDate,
    this.endDate,
    required this.situation,
    required this.isSelected,
  });

  factory TrainerEnrollmentPackageOptionModel.fromJson(Map<String, dynamic> json) {
    int readInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    final sel = json['is_selected'];
    final isSel = sel == true ||
        sel == 1 ||
        sel == '1' ||
        (sel is String && sel.toLowerCase() == 'true');

    return TrainerEnrollmentPackageOptionModel(
      memberRegisterId: readInt(json['member_register_id'] ?? json['memberRegisterId']),
      productPackageId: readInt(json['product_package_id'] ?? json['productPackageId']),
      name: json['name']?.toString() ?? '',
      remainingQty: json['remaining_qty'] != null ? readInt(json['remaining_qty']) : null,
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      situation: json['situation']?.toString() ?? '',
      isSelected: isSel,
    );
  }
}

/// Üst düzey `output` map — paket seçenekleri listesi.
class TrainerEnrollmentPackageOptionsOutputModel {
  final int? memberId;
  final int? currentMemberRegisterId;
  final List<int> allowedProductPackageIds;
  final List<TrainerEnrollmentPackageOptionModel> options;

  const TrainerEnrollmentPackageOptionsOutputModel({
    this.memberId,
    this.currentMemberRegisterId,
    this.allowedProductPackageIds = const [],
    this.options = const [],
  });

  factory TrainerEnrollmentPackageOptionsOutputModel.fromJson(Map<String, dynamic> json) {
    int? readOptInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    final rawOpts = json['options'];
    final opts = <TrainerEnrollmentPackageOptionModel>[];
    if (rawOpts is List) {
      for (final e in rawOpts) {
        if (e is Map<String, dynamic>) {
          opts.add(TrainerEnrollmentPackageOptionModel.fromJson(e));
        }
      }
    }

    final rawAllowed = json['allowed_product_package_ids'];
    final allowed = <int>[];
    if (rawAllowed is List) {
      for (final e in rawAllowed) {
        final i = readOptInt(e);
        if (i != null) allowed.add(i);
      }
    }

    return TrainerEnrollmentPackageOptionsOutputModel(
      memberId: readOptInt(json['member_id']),
      currentMemberRegisterId: readOptInt(json['current_member_register_id']),
      allowedProductPackageIds: allowed,
      options: opts,
    );
  }
}
