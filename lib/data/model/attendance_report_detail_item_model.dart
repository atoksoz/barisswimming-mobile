class AttendanceReportDetailItemModel {
  final int id;
  final String lessonName;
  final String employeeName;
  final String date;
  final String? time;
  final String type;
  final int attendance;
  final bool isCancelled;
  final bool isMakeup;

  const AttendanceReportDetailItemModel({
    required this.id,
    required this.lessonName,
    required this.employeeName,
    required this.date,
    required this.time,
    required this.type,
    required this.attendance,
    required this.isCancelled,
    required this.isMakeup,
  });

  factory AttendanceReportDetailItemModel.fromJson(Map<String, dynamic> json) {
    return AttendanceReportDetailItemModel(
      id: AttendanceReportDetailItemModel._int(json['id']),
      lessonName: json['lesson_name']?.toString() ?? '-',
      employeeName: json['employee_name']?.toString() ?? '-',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString(),
      type: json['type']?.toString() ?? '',
      attendance: AttendanceReportDetailItemModel._int(json['attendance']),
      isCancelled: json['is_cancelled'] == true,
      isMakeup: json['is_makeup'] == true,
    );
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  bool get isGroupLesson => type == 'group';

  /// Plan tarihi + saat: en yeni üstte (yoklama listesi ile aynı kural).
  static int compareByPlanDateTimeDesc(
    AttendanceReportDetailItemModel a,
    AttendanceReportDetailItemModel b,
  ) {
    try {
      final da = DateTime.parse(a.date);
      final db = DateTime.parse(b.date);
      final c = da.compareTo(db);
      if (c != 0) return -c;
    } catch (_) {
      return 0;
    }
    final ta = a.time ?? '';
    final tb = b.time ?? '';
    return -ta.compareTo(tb);
  }
}
