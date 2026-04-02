class MemberActionModel {
  static const String directionIn = 'in';
  static const String directionOut = 'out';

  final String direction;
  final String actionTime;

  MemberActionModel({
    required this.direction,
    required this.actionTime,
  });

  bool get isEntry => direction == directionIn;

  factory MemberActionModel.fromJson(Map<String, dynamic> json) {
    return MemberActionModel(
      direction: json["direction"] ?? '',
      actionTime: json['action_time'] ?? '',
    );
  }
}
