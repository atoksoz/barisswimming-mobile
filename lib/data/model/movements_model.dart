class MovementsModel {
  final String section_id;
  final String fitness_movement_id;
  final String fitness_movement_name;
  final String set;
  final String repeat;
  final String sort;
  final String default_image_url;
  final String default_video;
  final String section_name;
  final String explanation;
  final String detail;
  final int? duration;
  bool isDone;
  MovementsModel(
      {required this.section_id,
      required this.fitness_movement_id,
      required this.fitness_movement_name,
      required this.set,
      required this.repeat,
      required this.sort,
      required this.default_image_url,
      required this.default_video,
      required this.section_name,
      required this.explanation,
      required this.detail,
      this.duration,
      required this.isDone});

  factory MovementsModel.fromJson(Map<String, dynamic> json) {
    return MovementsModel(
      section_id: json["section_id"].toString(),
      fitness_movement_id: json['fitness_movement_id'].toString(),
      fitness_movement_name: json['fitness_movement_name'].toString(),
      set: json['set'].toString(),
      repeat: json['repeat'].toString(),
      sort: json['sort'].toString(),
      default_image_url: json['default_image_url'].toString(),
      default_video: json['default_video'] ?? "",
      section_name: json['section_name'] ?? "",
      explanation: json['explanation'] ?? "",
      detail: json['detail'] ?? "",
      duration: json['duration'] != null
          ? int.tryParse(json['duration'].toString())
          : null,
      isDone: false,
    );
  }
}
