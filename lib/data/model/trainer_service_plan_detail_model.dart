import 'package:e_sport_life/core/enums/service_period_type.dart';

/// Randevu `GET v2/me/service-plans/{id}` (Fitiz / `ServicePlanResource` uyumlu alanlar).
class TrainerServicePlanDetailModel {
  final int id;
  final String servicePlanName;
  final String? servicesId;
  final int? employeeId;
  final int personLimit;
  final int minLimit;
  final String planDatetime;
  final double durationHours;
  final String periodRaw;
  final bool trackPayment;
  final String? explanation;
  final int? groupLessonLocationId;

  const TrainerServicePlanDetailModel({
    required this.id,
    required this.servicePlanName,
    this.servicesId,
    this.employeeId,
    required this.personLimit,
    required this.minLimit,
    required this.planDatetime,
    required this.durationHours,
    required this.periodRaw,
    required this.trackPayment,
    this.explanation,
    this.groupLessonLocationId,
  });

  static int _asInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? fallback;
    return int.tryParse(v?.toString() ?? '') ?? fallback;
  }

  static double _asDouble(dynamic v, {double fallback = 1.0}) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  static bool _asBool(dynamic v) {
    if (v == true || v == 1 || v == '1') return true;
    if (v == false || v == 0 || v == '0') return false;
    return true;
  }

  static String? _servicesIdFromJson(Map<String, dynamic> json) {
    final raw = json['services_id'] ?? json['service_id'];
    if (raw == null) return null;
    final s = raw.toString().trim();
    return s.isEmpty ? null : s;
  }

  static int? _optionalPositiveInt(dynamic v) {
    if (v == null) return null;
    final n = _asInt(v, fallback: 0);
    return n > 0 ? n : null;
  }

  factory TrainerServicePlanDetailModel.fromJson(
    Map<String, dynamic> json, {
    /// URL’deki id bazen gövdede yok veya farklı anahtarda gelir.
    int? fallbackPlanId,
  }) {
    var id = _asInt(json['id']);
    if (id <= 0 && fallbackPlanId != null && fallbackPlanId > 0) {
      id = fallbackPlanId;
    }
    final name = json['service_plan_name']?.toString() ??
        json['title']?.toString() ??
        '';

    final planDt = json['plan_datetime']?.toString() ??
        json['planDatetime']?.toString() ??
        json['start']?.toString() ??
        json['starts_at']?.toString() ??
        json['startsAt']?.toString() ??
        '';

    return TrainerServicePlanDetailModel(
      id: id > 0 ? id : 0,
      servicePlanName: name,
      servicesId: _servicesIdFromJson(json),
      employeeId: _optionalPositiveInt(json['employee_id']),
      personLimit: _asInt(json['person_limit'], fallback: 1).clamp(1, 999999),
      minLimit: _asInt(json['min_limit'], fallback: 0).clamp(0, 999999),
      planDatetime: planDt,
      durationHours: _asDouble(json['duration_hours'], fallback: 1.0),
      periodRaw: json['period']?.toString() ?? ServicePeriodType.weekly.apiValue,
      trackPayment: _asBool(json['track_payment']),
      explanation: json['explanation']?.toString(),
      groupLessonLocationId: _optionalPositiveInt(json['group_lesson_location_id']),
    );
  }

  ServicePeriodType? resolvePeriod() {
    final v = periodRaw.trim().toUpperCase();
    for (final e in ServicePeriodType.values) {
      if (e.apiValue == v) return e;
    }
    return null;
  }
}
