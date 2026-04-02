import 'package:e_sport_life/core/extensions/format_datetime_extension.dart';

class PastFitnessProgrameModel {
  final String id;
  final String programe_name;
  final String created_at;

  PastFitnessProgrameModel({
    required this.id,
    required this.programe_name,
    required this.created_at,
  });

  factory PastFitnessProgrameModel.fromJson(Map<String, dynamic> json) {
    return PastFitnessProgrameModel(
      id: json["id"].toString(),
      programe_name: json['programe_name'].toString(),
      created_at: json['created_at'].toString().toFormattedDateTime(),
    );
  }
}
