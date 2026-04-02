class MyResarvationNowModel {
  final String id;
  final String date;
  final String time;
  final String resarvation_now_plan_name;
  final String employee_name;
  final String deleted_at;
  final String plan_date;
  final String is_today;
  final String? type;

  MyResarvationNowModel({
    required this.id,
    required this.date,
    required this.time,
    required this.resarvation_now_plan_name,
    required this.employee_name,
    required this.deleted_at,
    required this.plan_date,
    required this.is_today,
    this.type,
  });

  factory MyResarvationNowModel.fromJson(Map<String, dynamic> json) {
    return MyResarvationNowModel(
      id: json["id"].toString(),
      date: json['date'].toString(),
      time: json['time'].toString(),
      resarvation_now_plan_name: json['resarvation_now_plan_name'],
      employee_name: json['employee_name'],
      deleted_at: json['deleted_at'] ?? '',
      plan_date: json['plan_date'] ?? '',
      is_today: json['is_today']?.toString() ?? '',
      type: json['type']?.toString(),
    );
  }
}
