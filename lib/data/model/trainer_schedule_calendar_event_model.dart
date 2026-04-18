/// Randevu `GET v2/service-plans/calendar` çıktısı — Fitiz `useScheduleApi` / PHP
/// [ServicePlanRepository::getCalendarEvents] ile uyumlu alanlar.
///
/// `start` offsetsiz yerel duvar saati; `end` ISO8601 olabilir — aralık için
/// [DateFormatUtils.formatLocalHmRange] içinde [durationHours] kullanılır.
class TrainerScheduleCalendarEventModel {
  final String id;
  final int servicePlanId;
  final String title;
  final String start;
  final String end;
  final double? durationHours;
  final int? employeeId;
  final String employeeName;
  final String? locationName;
  final int? personLimit;
  final int minLimit;
  final int reservationCount;
  final bool isCancelled;
  final String type;
  /// Takvim satırında varsa düzenleme formu için (GET yedek).
  final String? servicesId;
  final int? groupLessonLocationId;

  const TrainerScheduleCalendarEventModel({
    required this.id,
    required this.servicePlanId,
    required this.title,
    required this.start,
    required this.end,
    this.durationHours,
    this.employeeId,
    required this.employeeName,
    this.locationName,
    this.personLimit,
    this.minLimit = 0,
    this.reservationCount = 0,
    required this.isCancelled,
    required this.type,
    this.servicesId,
    this.groupLessonLocationId,
  });

  factory TrainerScheduleCalendarEventModel.fromJson(
    Map<String, dynamic> json,
  ) {
    int? readInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '');
    }

    String? readServicesId(Map<String, dynamic> m) {
      final raw = m['services_id'] ?? m['service_id'] ?? m['servicesId'];
      if (raw == null) return null;
      final s = raw.toString().trim();
      return s.isEmpty ? null : s;
    }

    int? readLocationId(Map<String, dynamic> m) {
      final raw = m['group_lesson_location_id'] ??
          m['location_id'] ??
          m['groupLessonLocationId'] ??
          m['locationId'];
      if (raw == null) return null;
      return readInt(raw);
    }

    int? pid = json['service_plan_id'] is int
        ? json['service_plan_id'] as int
        : int.tryParse(json['service_plan_id']?.toString() ?? '');

    final ext = json['extendedProps'];
    if (ext is Map) {
      final em = Map<String, dynamic>.from(ext);
      if (pid == null || pid == 0) {
        pid = readInt(em['service_plan_id']) ?? readInt(em['servicePlanId']);
      }
    }

    final idStr = json['id']?.toString() ?? '';
    if (pid == null || pid == 0) {
      if (RegExp(r'^\d+$').hasMatch(idStr)) {
        pid = int.tryParse(idStr);
      }
    }
    pid ??= 0;

    final sid = idStr;

    Map<String, dynamic>? extMap;
    if (ext is Map) {
      extMap = Map<String, dynamic>.from(ext);
    }

    final servicesId = readServicesId(json) ??
        (extMap != null ? readServicesId(extMap) : null);
    int? gloc = readLocationId(json) ??
        (extMap != null ? readLocationId(extMap) : null);
    if (gloc != null && gloc <= 0) gloc = null;

    final rawRes = json['reservations'];
    final resCount = rawRes is List ? rawRes.length : 0;

    final rawMin = json['min_limit'];
    final minLim = rawMin is int
        ? rawMin
        : int.tryParse(rawMin?.toString() ?? '') ?? 0;

    final rawDur = json['duration_hours'] ?? json['durationHours'];
    final double? durH = rawDur == null
        ? null
        : (rawDur is num ? rawDur.toDouble() : double.tryParse(rawDur.toString()));

    return TrainerScheduleCalendarEventModel(
      id: sid,
      servicePlanId: pid,
      title: json['title']?.toString() ?? '',
      start: json['start']?.toString() ?? '',
      end: json['end']?.toString() ?? '',
      durationHours: durH != null && durH > 0 ? durH : null,
      employeeId: json['employee_id'] is int
          ? json['employee_id'] as int
          : int.tryParse(json['employee_id']?.toString() ?? ''),
      employeeName: json['employee_name']?.toString() ?? '',
      locationName: json['location_name']?.toString(),
      personLimit: json['person_limit'] is int
          ? json['person_limit'] as int
          : int.tryParse(json['person_limit']?.toString() ?? ''),
      minLimit: minLim,
      reservationCount: resCount,
      isCancelled: json['is_cancelled'] == true ||
          json['is_cancelled'] == 1 ||
          json['is_cancelled'] == '1',
      type: json['type']?.toString() ?? 'group',
      servicesId: servicesId,
      groupLessonLocationId: gloc,
    );
  }
}
