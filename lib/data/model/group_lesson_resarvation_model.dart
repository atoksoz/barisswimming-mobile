import 'package:intl/intl.dart';

class GroupLessonResarvationModel {
  final int id;
  final String servicePlanName;
  final String employeeName;
  final String planTime; // "18:00:00"
  final String resarvationDate; // "2025-07-25"
  final String dayName;
  final String? deletedAt;
  //meslek
  //açıklama

  GroupLessonResarvationModel({
    required this.id,
    required this.servicePlanName,
    required this.employeeName,
    required this.planTime,
    required this.resarvationDate,
    required this.dayName,
    this.deletedAt,
  });

  /// Formatlanmış tarih: 25-07-2025
  String get formattedDate {
    try {
      final date = DateTime.parse(resarvationDate);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (_) {
      return resarvationDate;
    }
  }

  /// Formatlanmış saat: 18:00
  String get formattedTime {
    try {
      final time = DateFormat('HH:mm:ss').parse(planTime);
      return DateFormat('HH:mm').format(time);
    } catch (_) {
      return planTime;
    }
  }

  factory GroupLessonResarvationModel.fromJson(Map<String, dynamic> json) {
    return GroupLessonResarvationModel(
      id: json['id'],
      servicePlanName: json['service_plan_name'],
      employeeName: json['employee_name'],
      planTime: json['plan_time'],
      resarvationDate: json['resarvation_date'],
      dayName: json['day_name'],
      deletedAt: json['deleted_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_plan_name': servicePlanName,
      'employee_name': employeeName,
      'plan_time': planTime,
      'resarvation_date': resarvationDate,
      'day_name': dayName,
      'deleted_at': deletedAt,
    };
  }
}
