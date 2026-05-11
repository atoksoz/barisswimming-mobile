/// Randevu takvim olayı `enrollments[]` satırı (kayıtlı öğrenciler).
class TrainerCalendarEnrollmentRowModel {
  final int id;
  final int? memberRegisterId;
  final String memberName;
  final int? userId;
  final int status;

  const TrainerCalendarEnrollmentRowModel({
    required this.id,
    this.memberRegisterId,
    required this.memberName,
    this.userId,
    required this.status,
  });

  factory TrainerCalendarEnrollmentRowModel.fromJson(Map<String, dynamic> json) {
    int? readInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '');
    }

    return TrainerCalendarEnrollmentRowModel(
      id: readInt(json['id']) ?? 0,
      memberRegisterId: readInt(json['member_register_id'] ?? json['memberRegisterId']),
      memberName: json['member_name']?.toString() ?? '',
      userId: readInt(json['user_id'] ?? json['userId']),
      status: readInt(json['status']) ?? 0,
    );
  }
}
