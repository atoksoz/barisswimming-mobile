// Randevu `GET /api/v2/me/employee/stats|lessons` (`api_v2_trainer`) yanıtları için modeller.

int _intField(Map<String, dynamic>? map, List<String> keys, {int fallback = 0}) {
  if (map == null) return fallback;
  for (final k in keys) {
    final v = map[k];
    if (v == null) continue;
    if (v is int) return v;
    if (v is num) return v.toInt();
    final p = int.tryParse(v.toString());
    if (p != null) return p;
  }
  return fallback;
}

/// `GET …/employees/{id}/stats` çıktısı (alan adları backend’e göre esnek).
class TrainerEmployeeWeeklyStatsModel {
  const TrainerEmployeeWeeklyStatsModel({
    required this.weeklyNormalCount,
    required this.weeklyMakeupCount,
    required this.weeklyTotalCount,
  });

  final int weeklyNormalCount;
  final int weeklyMakeupCount;
  final int weeklyTotalCount;

  factory TrainerEmployeeWeeklyStatsModel.fromOutputMap(Map<String, dynamic> map) {
    /// Randevu `GET v2/me/employee/stats`: `group_lesson_count`, `individual_count`,
    /// `monthly_total` — eski uçlar: `weekly_*`.
    final normal = _intField(map, [
      'weekly_normal_count',
      'weekly_normal_lesson_count',
      'normal_lesson_count',
      'group_lesson_count',
    ]);
    final makeupOrIndividual = _intField(map, [
      'weekly_makeup_count',
      'weekly_makeup_lesson_count',
      'makeup_lesson_count',
      'individual_count',
    ]);
    var total = _intField(map, [
      'weekly_total_count',
      'weekly_total',
      'monthly_total',
    ]);
    final sumParts = normal + makeupOrIndividual;
    if (total == 0 && sumParts > 0) {
      total = sumParts;
    }
    return TrainerEmployeeWeeklyStatsModel(
      weeklyNormalCount: normal,
      weeklyMakeupCount: makeupOrIndividual,
      weeklyTotalCount: total,
    );
  }
}

/// `GET …/employees/{id}/lessons` liste öğesi (takvim/satır yapısı).
class TrainerEmployeeLessonListItemModel {
  const TrainerEmployeeLessonListItemModel({
    required this.title,
    this.startIso,
    this.locationName,
    this.lessonType,
  });

  final String title;
  final String? startIso;
  final String? locationName;
  final String? lessonType;

  factory TrainerEmployeeLessonListItemModel.fromDynamic(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      return const TrainerEmployeeLessonListItemModel(title: '');
    }
    final m = raw;
    final title = (m['title'] ??
            m['service_plan_name'] ??
            m['lesson_name'] ??
            m['name'] ??
            '')
        .toString()
        .trim();
    final start = m['start'] ?? m['start_at'] ?? m['plan_start'];
    return TrainerEmployeeLessonListItemModel(
      title: title.isEmpty ? '—' : title,
      startIso: start?.toString(),
      locationName: (m['location_name'] ?? m['locationName'])?.toString(),
      lessonType: (m['type'] ?? m['lesson_type'])?.toString(),
    );
  }

  static List<TrainerEmployeeLessonListItemModel> listFromResponse(dynamic output) {
    if (output is List) {
      return output
          .map(TrainerEmployeeLessonListItemModel.fromDynamic)
          .toList();
    }
    if (output is Map<String, dynamic>) {
      final inner = output['lessons'] ?? output['data'];
      if (inner is List) {
        return inner.map(TrainerEmployeeLessonListItemModel.fromDynamic).toList();
      }
    }
    return [];
  }
}

/// `GET v2/me/employee/lessons` — `output.lessons[]` içinde öğrenci başına satır.
class TrainerEmployeeLessonParticipantModel {
  const TrainerEmployeeLessonParticipantModel({
    required this.id,
    required this.studentName,
    this.studentPhone,
    required this.attendance,
  });

  final int id;
  final String studentName;
  final String? studentPhone;
  /// Randevu [ReservationAttendanceValue] ile uyumlu (0/1/2).
  final int attendance;
}

/// Aynı ders oturumu (tarih + saat + ders adı) altında gruplanmış katılımcılar.
class TrainerEmployeeLessonSessionModel {
  const TrainerEmployeeLessonSessionModel({
    required this.lessonName,
    required this.dateYmd,
    required this.timeHm,
    required this.type,
    required this.isMakeup,
    required this.participants,
  });

  final String lessonName;
  final String dateYmd;
  final String timeHm;
  final String type;
  final bool isMakeup;
  final List<TrainerEmployeeLessonParticipantModel> participants;

  /// [output] genelde `{ "total": n, "lessons": [ ... ] }` veya doğrudan liste.
  static List<TrainerEmployeeLessonSessionModel> sessionsFromOutput(
    dynamic output,
  ) {
    final rows = _flatLessonRows(output);
    if (rows.isEmpty) return [];

    final groups = <String, List<Map<String, dynamic>>>{};
    for (final m in rows) {
      final name =
          (m['lesson_name'] ?? m['lessonName'] ?? '').toString().trim();
      final date = (m['date'] ?? '').toString().trim();
      final time = (m['time'] ?? '').toString().trim();
      final key = '$date|$time|$name';
      groups.putIfAbsent(key, () => []).add(m);
    }

    final sessions = <TrainerEmployeeLessonSessionModel>[];
    for (final list in groups.values) {
      if (list.isEmpty) continue;
      final first = list.first;
      final lessonName =
          (first['lesson_name'] ?? first['lessonName'] ?? '—').toString().trim();
      final dateYmd = (first['date'] ?? '').toString().trim();
      final timeHm = (first['time'] ?? '').toString().trim();

      final participants = <TrainerEmployeeLessonParticipantModel>[];
      for (final m in list) {
        participants.add(
          TrainerEmployeeLessonParticipantModel(
            id: _intField(m, ['id']),
            studentName:
                (m['student_name'] ?? m['studentName'] ?? '—').toString().trim(),
            studentPhone: _nullableTrim(m['student_phone'] ?? m['studentPhone']),
            attendance: _intField(m, ['attendance']),
          ),
        );
      }
      participants.sort(
        (a, b) => a.studentName.toLowerCase().compareTo(b.studentName.toLowerCase()),
      );

      final makeup = list.any(
        (m) =>
            m['is_makeup'] == true ||
            m['is_makeup'] == 1 ||
            m['isMakeup'] == true,
      );

      sessions.add(
        TrainerEmployeeLessonSessionModel(
          lessonName: lessonName.isEmpty ? '—' : lessonName,
          dateYmd: dateYmd,
          timeHm: timeHm,
          type: (first['type'] ?? 'group').toString(),
          isMakeup: makeup,
          participants: participants,
        ),
      );
    }

    sessions.sort((a, b) {
      final byDate = a.dateYmd.compareTo(b.dateYmd);
      if (byDate != 0) return byDate;
      return a.timeHm.compareTo(b.timeHm);
    });
    return sessions;
  }

  static List<Map<String, dynamic>> _flatLessonRows(dynamic output) {
    final rows = <Map<String, dynamic>>[];
    void takeList(List? list) {
      if (list == null) return;
      for (final e in list) {
        if (e is Map<String, dynamic>) {
          rows.add(e);
        } else if (e is Map) {
          rows.add(Map<String, dynamic>.from(e));
        }
      }
    }

    if (output is Map<String, dynamic>) {
      final lessons = output['lessons'];
      if (lessons is List) takeList(lessons);
    } else if (output is List) {
      takeList(output);
    }
    return rows;
  }

  static String? _nullableTrim(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}
