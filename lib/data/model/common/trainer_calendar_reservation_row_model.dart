import 'package:e_sport_life/core/constants/reservation_attendance.dart';

/// Randevu takvim olayı `reservations[]` satırı.
class TrainerCalendarReservationRowModel {
  final int id;
  final String memberName;
  final int? memberRegisterId;
  final int? userId;
  final int attendance;

  const TrainerCalendarReservationRowModel({
    required this.id,
    required this.memberName,
    this.memberRegisterId,
    this.userId,
    required this.attendance,
  });

  factory TrainerCalendarReservationRowModel.fromJson(Map<String, dynamic> json) {
    int? readInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '');
    }

    final uid = readInt(json['user_id'] ?? json['userId'] ?? json['member_id']);
    return TrainerCalendarReservationRowModel(
      id: readInt(json['id']) ?? 0,
      memberName: json['member_name']?.toString() ?? '',
      memberRegisterId: readInt(json['member_register_id'] ?? json['memberRegisterId']),
      userId: uid,
      attendance: readInt(json['attendance']) ?? ReservationAttendanceValue.notAttended,
    );
  }
}
