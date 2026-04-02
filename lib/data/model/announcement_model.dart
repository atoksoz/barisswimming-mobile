class AnnouncementModel {
  final int id;
  final String title;
  final String description;
  final String createdAt;
  final String updatedAt;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static List<AnnouncementModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => AnnouncementModel.fromJson(json)).toList();
  }
}

