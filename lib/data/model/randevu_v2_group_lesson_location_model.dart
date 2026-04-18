/// Eğitmen: `GET api/v2/me/group-lesson-locations` — [GroupLessonLocationListResource].
class RandevuV2GroupLessonLocationModel {
  final int id;
  final String name;

  const RandevuV2GroupLessonLocationModel({
    required this.id,
    required this.name,
  });

  /// API `name` boşsa bile seçicide metin gösterilsin.
  String get displayLabel => name.isNotEmpty ? name : '#$id';

  factory RandevuV2GroupLessonLocationModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '') ?? 0;
    final name = (json['name'] ?? json['title'] ?? json['label'] ?? '')
        .toString()
        .trim();
    return RandevuV2GroupLessonLocationModel(
      id: id,
      name: name,
    );
  }
}
