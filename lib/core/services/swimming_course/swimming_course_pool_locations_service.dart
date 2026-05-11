import 'dart:convert';

import 'package:e_sport_life/core/constants/url/randevu_al_url_constants.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/services/swimming_course/trainer_service_plan_form_service.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/data/model/randevu_v2_group_lesson_location_model.dart';
import 'package:flutter/foundation.dart';

/// Yüzme kursu — Randevu’daki grup ders lokasyonları (havuzlar); harita / koordinat.
class SwimmingCoursePoolLocationsService {
  SwimmingCoursePoolLocationsService._();

  /// Üye JWT — `GET api/v2/me/pool-locations` ([api_v2_member.php]).
  static Future<List<RandevuV2GroupLessonLocationModel>> fetchForMember({
    required String randevuBaseUrl,
    String? token,
  }) async {
    final t = token ?? await JwtStorageService.getToken();
    final url =
        RandevuAlUrlConstants.getMemberPoolLocationsUrl(randevuBaseUrl);
    final res = await RequestUtil.getJson(url, token: t);
    _debugPrintFullHttpJson('member', url, res);
    if (!res.isSuccess || res.output == null) return const [];
    _debugLogPoolLocationsRaw('member', url, res.output);
    final list = TrainerServicePlanFormService.parseLocationList(res.output);
    _debugLogPoolLocationsParsed('member', list);
    return list;
  }

  /// Eğitmen JWT — `GET api/v2/me/group-lesson-locations`.
  static Future<List<RandevuV2GroupLessonLocationModel>> fetchForTrainer({
    required String randevuBaseUrl,
    String? token,
  }) async {
    final t = token ?? await JwtStorageService.getToken();
    final url =
        RandevuAlUrlConstants.getV2GroupLessonLocationsUrl(randevuBaseUrl);
    final res = await RequestUtil.getJson(url, token: t);
    _debugPrintFullHttpJson('trainer', url, res);
    if (!res.isSuccess || res.output == null) return const [];
    _debugLogPoolLocationsRaw('trainer', url, res.output);
    final list = TrainerServicePlanFormService.parseLocationList(res.output);
    _debugLogPoolLocationsParsed('trainer', list);
    return list;
  }

  /// Tam API JSON gövdesi (`status`, `output`, …). Hata yanıtında da çalışır.
  static void _debugPrintFullHttpJson(
    String role,
    String requestUrl,
    ApiResponse res,
  ) {
    if (!kDebugMode) return;
    try {
      debugPrint(
        '[PoolLocations][$role] FULL HTTP JSON url=$requestUrl '
        'statusCode=${res.statusCode} isSuccess=${res.isSuccess}',
      );
      final b = res.body;
      if (b == null) {
        debugPrint('[PoolLocations][$role] body: null');
        return;
      }
      if (b is Map || b is List) {
        debugPrint(
          '[PoolLocations][$role] body:\n'
          '${const JsonEncoder.withIndent('  ').convert(b)}',
        );
      } else {
        debugPrint('[PoolLocations][$role] body (raw): $b');
      }
    } catch (e, st) {
      debugPrint('[PoolLocations][$role] full JSON log error: $e\n$st');
    }
  }

  static void _debugLogPoolLocationsRaw(
    String role,
    String requestUrl,
    dynamic output,
  ) {
    if (!kDebugMode) return;
    try {
      debugPrint('[PoolLocations][$role] URL: $requestUrl');
      debugPrint('[PoolLocations][$role] output runtimeType: ${output.runtimeType}');
      if (output is List) {
        debugPrint('[PoolLocations][$role] output list length: ${output.length}');
        if (output.isNotEmpty) {
          final first = output.first;
          if (first is Map) {
            final m = Map<String, dynamic>.from(first);
            debugPrint(
              '[PoolLocations][$role] first item keys: ${m.keys.toList()}',
            );
            debugPrint(
              '[PoolLocations][$role] first item JSON:\n'
              '${const JsonEncoder.withIndent('  ').convert(m)}',
            );
          }
        }
      } else if (output is Map) {
        final m = Map<String, dynamic>.from(output);
        debugPrint('[PoolLocations][$role] output map keys: ${m.keys.toList()}');
        debugPrint(
          '[PoolLocations][$role] output JSON:\n'
          '${const JsonEncoder.withIndent('  ').convert(m)}',
        );
      } else {
        debugPrint('[PoolLocations][$role] output toString: $output');
      }
    } catch (e, st) {
      debugPrint('[PoolLocations][$role] raw log error: $e\n$st');
    }
  }

  static void _debugLogPoolLocationsParsed(
    String role,
    List<RandevuV2GroupLessonLocationModel> list,
  ) {
    if (!kDebugMode) return;
    try {
      debugPrint('[PoolLocations][$role] parsed count: ${list.length}');
      for (final l in list) {
        debugPrint(
          '[PoolLocations][$role] id=${l.id} name="${l.name}" '
          'address="${l.address}" lat=${l.latitude} lng=${l.longitude}',
        );
      }
    } catch (e, st) {
      debugPrint('[PoolLocations][$role] parsed log error: $e\n$st');
    }
  }
}
