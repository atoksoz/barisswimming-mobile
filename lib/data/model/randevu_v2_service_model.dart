/// `GET v2/services` satırı — [ServiceResource].
class RandevuV2ServiceModel {
  final String id;
  final String name;
  final String? detail;
  final String? color;

  const RandevuV2ServiceModel({
    required this.id,
    required this.name,
    this.detail,
    this.color,
  });

  factory RandevuV2ServiceModel.fromJson(Map<String, dynamic> json) {
    return RandevuV2ServiceModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      detail: json['detail']?.toString(),
      color: json['color']?.toString(),
    );
  }
}
