// Randevu `v2/me/today-summary` — eğitmen anasayfa rozetleri ve popup listeleri.

int _asInt(dynamic v, {int fallback = 0}) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? fallback;
}

class TrainerTodayAttendanceModel {
  const TrainerTodayAttendanceModel({
    required this.id,
    required this.memberName,
    this.lessonName,
    this.planTime,
    this.note,
  });

  final int id;
  final String memberName;
  /// Randevu `today-summary` satırı — backend `lesson_name` / `plan_name` vb.
  final String? lessonName;
  final String? planTime;
  final String? note;

  factory TrainerTodayAttendanceModel.fromJson(Map<String, dynamic> json) {
    String? lessonNameFromJson() {
      for (final k in [
        'lesson_name',
        'lessonName',
        'plan_name',
        'service_plan_name',
        'lesson_title',
      ]) {
        final v = json[k];
        if (v == null) continue;
        final s = v.toString().trim();
        if (s.isNotEmpty) return s;
      }
      return null;
    }

    return TrainerTodayAttendanceModel(
      id: _asInt(json['id']),
      memberName: (json['member_name'] as String?)?.trim() ?? '',
      lessonName: lessonNameFromJson(),
      planTime: json['plan_time'] as String?,
      note: (json['note'] as String?)?.trim(),
    );
  }
}

class TrainerTodayGroupLessonModel {
  const TrainerTodayGroupLessonModel({
    required this.id,
    required this.name,
    this.startTime,
    this.endTime,
    this.locationName,
    this.enrollmentCount,
    this.capacity,
  });

  final int id;
  final String name;
  final String? startTime;
  final String? endTime;
  final String? locationName;
  final int? enrollmentCount;
  final int? capacity;

  factory TrainerTodayGroupLessonModel.fromJson(Map<String, dynamic> json) {
    return TrainerTodayGroupLessonModel(
      id: _asInt(json['id']),
      name: (json['name'] as String?)?.trim() ?? '',
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      locationName: json['location_name'] as String?,
      enrollmentCount: json['enrollment_count'] == null
          ? null
          : _asInt(json['enrollment_count']),
      capacity:
          json['capacity'] == null ? null : _asInt(json['capacity']),
    );
  }
}

class TrainerTodayPtPlanModel {
  const TrainerTodayPtPlanModel({
    required this.id,
    required this.name,
    required this.times,
  });

  final int id;
  final String name;
  final List<String> times;

  factory TrainerTodayPtPlanModel.fromJson(Map<String, dynamic> json) {
    final raw = json['times'];
    final list = raw is List
        ? raw.map((e) => e.toString()).toList()
        : const <String>[];
    return TrainerTodayPtPlanModel(
      id: _asInt(json['id']),
      name: (json['name'] as String?)?.trim() ?? '',
      times: list,
    );
  }
}

class TrainerTodayQuickReservationModel {
  const TrainerTodayQuickReservationModel({
    required this.id,
    required this.memberName,
    this.planTime,
    this.attendance,
  });

  final int id;
  final String memberName;
  final String? planTime;
  final int? attendance;

  factory TrainerTodayQuickReservationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TrainerTodayQuickReservationModel(
      id: _asInt(json['id']),
      memberName: (json['member_name'] as String?)?.trim() ?? '',
      planTime: json['plan_time'] as String?,
      attendance:
          json['attendance'] == null ? null : _asInt(json['attendance']),
    );
  }
}

class TrainerTodayRecentReservationModel {
  const TrainerTodayRecentReservationModel({
    required this.id,
    required this.memberName,
    this.planName,
    this.planDate,
    this.planTime,
    this.note,
    this.attendance,
  });

  final int id;
  final String memberName;
  final String? planName;
  final String? planDate;
  final String? planTime;
  final String? note;
  final int? attendance;

  factory TrainerTodayRecentReservationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TrainerTodayRecentReservationModel(
      id: _asInt(json['id']),
      memberName: (json['member_name'] as String?)?.trim() ?? '',
      planName: json['plan_name'] as String?,
      planDate: json['plan_date'] as String?,
      planTime: json['plan_time'] as String?,
      note: json['note'] as String?,
      attendance:
          json['attendance'] == null ? null : _asInt(json['attendance']),
    );
  }

  Map<String, dynamic> toRecentListMap() => {
        'id': id,
        'member_name': memberName,
        'plan_name': planName,
        'plan_date': planDate,
        'plan_time': planTime,
        'note': note,
        'attendance': attendance,
      };
}

class TrainerTodayDashboardModel {
  const TrainerTodayDashboardModel({
    required this.date,
    required this.groupLessons,
    required this.ptPlans,
    required this.quickReservations,
    required this.todayAttendances,
    required this.recentReservations,
  });

  final String date;
  final List<TrainerTodayGroupLessonModel> groupLessons;
  final List<TrainerTodayPtPlanModel> ptPlans;
  final List<TrainerTodayQuickReservationModel> quickReservations;
  final List<TrainerTodayAttendanceModel> todayAttendances;
  final List<TrainerTodayRecentReservationModel> recentReservations;

  int get lessonsBadgeCount => groupLessons.length + ptPlans.length;

  int get attendanceBadgeCount => todayAttendances.length;

  /// Özet popup satır sayısı (grup + PT + hızlı randevu).
  int get summaryBadgeCount =>
      groupLessons.length + ptPlans.length + quickReservations.length;

  static List<T> _parseList<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) fromRow,
  ) {
    if (raw is! List) return const [];
    return raw
        .map((e) {
          if (e is! Map) return null;
          return fromRow(Map<String, dynamic>.from(e));
        })
        .whereType<T>()
        .toList();
  }

  factory TrainerTodayDashboardModel.fromJson(Map<String, dynamic> json) {
    return TrainerTodayDashboardModel(
      date: json['date'] as String? ?? '',
      groupLessons: _parseList(
        json['group_lessons'],
        TrainerTodayGroupLessonModel.fromJson,
      ),
      ptPlans: _parseList(
        json['pt_plans'],
        TrainerTodayPtPlanModel.fromJson,
      ),
      quickReservations: _parseList(
        json['quick_reservations'],
        TrainerTodayQuickReservationModel.fromJson,
      ),
      todayAttendances: _parseList(
        json['today_attendances'],
        TrainerTodayAttendanceModel.fromJson,
      ),
      recentReservations: _parseList(
        json['recent_reservations'],
        TrainerTodayRecentReservationModel.fromJson,
      ),
    );
  }
}
