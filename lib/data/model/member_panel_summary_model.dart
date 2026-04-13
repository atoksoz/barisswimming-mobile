/// `GET v2/me/panel-summary` yanıtı (`output` gövdesi).
class MemberPanelSummaryModel {
  final int activePackageCount;
  /// Bugün vadesi gelen ve ödenmemiş planlı ödeme adedi (backend tanımı).
  final int todayUnpaidPaymentCount;

  const MemberPanelSummaryModel({
    required this.activePackageCount,
    required this.todayUnpaidPaymentCount,
  });

  static const MemberPanelSummaryModel zero = MemberPanelSummaryModel(
    activePackageCount: 0,
    todayUnpaidPaymentCount: 0,
  );

  factory MemberPanelSummaryModel.fromJson(Map<String, dynamic> json) {
    return MemberPanelSummaryModel(
      activePackageCount:
          (json['active_package_count'] as num?)?.toInt() ?? 0,
      todayUnpaidPaymentCount:
          (json['today_payment_count'] as num?)?.toInt() ?? 0,
    );
  }
}
