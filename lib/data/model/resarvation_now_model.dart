class ResarvationNowModel {
  final String id;
  final String date;
  final String day_number;
  final String day_name;
  final String resarvation_now_plan_name;
  final String employee_name;

  ResarvationNowModel({
    required this.id,
    required this.date,
    required this.day_number,
    required this.day_name,
    required this.resarvation_now_plan_name,
    required this.employee_name,
  });

  factory ResarvationNowModel.fromJson(Map<String, dynamic> json) {
    return ResarvationNowModel(
      id: json["id"].toString(),
      date: json['date'],
      day_number: json['day_number'].toString(),
      day_name: json["day_name"],
      resarvation_now_plan_name: json['resarvation_now_plan_name'],
      employee_name: json['employee_name'],
    );
  }
}
