class IsDoneMovementModel {
  final String fitnessMovementId;
  final String day; // YYYY-MM-DD formatında tarih
  bool isDone;

  IsDoneMovementModel({
    required this.fitnessMovementId,
    required this.day,
    required this.isDone,
  });

  factory IsDoneMovementModel.fromJson(Map<String, dynamic> json) {
    return IsDoneMovementModel(
      fitnessMovementId: json['fitness_movement_id'],
      day: json['day'],
      isDone: json['is_done'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fitness_movement_id': fitnessMovementId,
      'day': day,
      'is_done': isDone,
    };
  }
}
