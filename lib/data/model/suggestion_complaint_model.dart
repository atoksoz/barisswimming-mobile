class SuggestionComplaintModel {
  final int id;
  final int memberId;
  final String title;
  final String details;
  final DateTime createdAt;

  SuggestionComplaintModel({
    required this.id,
    required this.memberId,
    required this.title,
    required this.details,
    required this.createdAt,
  });

  factory SuggestionComplaintModel.fromJson(Map<String, dynamic> json) {
    return SuggestionComplaintModel(
      id: json['id'],
      memberId: json['member_id'],
      title: json['title'],
      details: json['details'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get createdDate {
    return "${createdAt.day.toString().padLeft(2, '0')}/"
        "${createdAt.month.toString().padLeft(2, '0')}/"
        "${createdAt.year}";
  }
}
