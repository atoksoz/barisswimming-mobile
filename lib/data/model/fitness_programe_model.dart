class FitnessProgrameModel {
  final String id;
  final String day;
  final String day_text;
  final String programe_name;
  final String description;

  FitnessProgrameModel({
    required this.id,
    required this.day,
    required this.day_text,
    required this.programe_name,
    required this.description,
  });

  factory FitnessProgrameModel.fromJson(Map<String, dynamic> json) {
    return FitnessProgrameModel(
      id: json["id"].toString(),
      day: json["day"].toString(),
      day_text: json['day_text'].toString(),
      programe_name: json['programe_name'].toString(),
      description: json['description']
    );
  }
}
