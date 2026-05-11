import 'dart:convert';

import 'package:e_sport_life/core/constants/url/randevu_al_url_constants.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/data/model/randevu_v2_group_lesson_location_model.dart';
import 'package:e_sport_life/data/model/randevu_v2_service_model.dart';
import 'package:e_sport_life/data/model/trainer_service_plan_detail_model.dart';

/// Yüzme eğitmeni — grup ders planı (Fitiz schedule POST gövdesi ile uyumlu).
class TrainerServicePlanFormService {
  TrainerServicePlanFormService._();

  /// Eğitmen JWT — yalnızca Randevu `v2/me/service-plans/{id}` (`api_v2_trainer.php`).
  ///
  /// `api/mobile/service-plans/…` yedeği kaldırıldı: birçok ortamda bu rota yok; HTTP 200 + gövde
  /// `status` hatası (409 vb.) sonrası ikinci URL’e düşmek yanlış “not found” gösteriyordu.
  static List<String> _servicePlanByIdUrls(String randevuBaseUrl, int servicePlanId) {
    return <String>[
      RandevuAlUrlConstants.getV2ServicePlanByIdUrl(randevuBaseUrl, servicePlanId),
    ];
  }

  static List<dynamic>? _unwrapList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map) {
      for (final key in ['data', 'items', 'locations', 'output']) {
        final v = raw[key];
        if (v is List) return v;
      }
    }
    return null;
  }

  static List<RandevuV2ServiceModel> _parseServiceList(dynamic raw) {
    final list = _unwrapList(raw);
    if (list == null) return const [];
    return list
        .map((e) => RandevuV2ServiceModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .where((s) => s.id.isNotEmpty)
        .toList();
  }

  static List<RandevuV2GroupLessonLocationModel> parseLocationList(dynamic raw) {
    final list = _unwrapList(raw);
    if (list == null) return const [];
    return list
        .map(
          (e) => RandevuV2GroupLessonLocationModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .where((l) => l.id > 0)
        .toList();
  }

  static Future<List<RandevuV2ServiceModel>> fetchServices({
    required String randevuBaseUrl,
    required String applicationTypeValue,
    String? token,
  }) async {
    final t = token ?? await JwtStorageService.getToken();
    final url = RandevuAlUrlConstants.getV2ServicesUrl(
      randevuBaseUrl,
      applicationType: applicationTypeValue,
    );
    final res = await RequestUtil.getJson(url, token: t);
    if (!res.isSuccess || res.output == null) return const [];
    return _parseServiceList(res.output);
  }

  static Future<List<RandevuV2GroupLessonLocationModel>> fetchLocations({
    required String randevuBaseUrl,
    String? token,
  }) async {
    final t = token ?? await JwtStorageService.getToken();
    final url = RandevuAlUrlConstants.getV2GroupLessonLocationsUrl(randevuBaseUrl);
    final res = await RequestUtil.getJson(url, token: t);
    if (!res.isSuccess || res.output == null) return const [];
    return parseLocationList(res.output);
  }

  static Future<ApiResponse> createServicePlan({
    required String randevuBaseUrl,
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final t = token ?? await JwtStorageService.getToken();
    final url = RandevuAlUrlConstants.getV2ServicePlansRootUrl(randevuBaseUrl);
    return RequestUtil.postJson(url, body: body, token: t);
  }

  static bool _mapLooksLikeServicePlan(Map<String, dynamic> m) {
    if (m.containsKey('plan_datetime') && m['plan_datetime'] != null) {
      return m['plan_datetime'].toString().trim().isNotEmpty;
    }
    if (m.containsKey('start') && m['start'] != null) {
      return m['start'].toString().trim().isNotEmpty;
    }
    return m.containsKey('service_plan_name') &&
        (m.containsKey('services_id') || m.containsKey('service_id'));
  }

  /// Randevu cevabı tek map, `output` içi, veya `service_plan` sarmalayıcısı olabilir.
  static Map<String, dynamic>? _extractPlanMapFromResponse(ApiResponse res) {
    if (!res.isSuccess) return null;
    final body = res.body;
    if (body is! Map) return null;
    final root = Map<String, dynamic>.from(body);

    dynamic node = root['output'] ?? root['data'];
    if (node == null && _mapLooksLikeServicePlan(root)) {
      return root;
    }
    return _deepUnwrapPlanNode(node);
  }

  static Map<String, dynamic>? _deepUnwrapPlanNode(dynamic node) {
    if (node == null) return null;
    if (node is String) {
      final s = node.trim();
      if (s.isEmpty) return null;
      try {
        return _deepUnwrapPlanNode(jsonDecode(s));
      } catch (_) {
        return null;
      }
    }
    if (node is List && node.isNotEmpty) {
      return _deepUnwrapPlanNode(node.first);
    }
    if (node is Map) {
      final m = Map<String, dynamic>.from(node);
      if (_mapLooksLikeServicePlan(m)) return m;
      for (final key in [
        'service_plan',
        'plan',
        'item',
        'model',
        'record',
        'output',
        'data',
      ]) {
        final inner = m[key];
        final found = _deepUnwrapPlanNode(inner);
        if (found != null) return found;
      }
    }
    return null;
  }

  static Future<TrainerServicePlanDetailModel?> fetchServicePlanById({
    required String randevuBaseUrl,
    required int servicePlanId,
    String? token,
  }) async {
    final t = token ?? await JwtStorageService.getToken();
    final urls = _servicePlanByIdUrls(randevuBaseUrl, servicePlanId);

    for (final url in urls) {
      final res = await RequestUtil.getJson(url, token: t);
      final map = _extractPlanMapFromResponse(res);
      if (map == null) continue;
      final model = TrainerServicePlanDetailModel.fromJson(
        map,
        fallbackPlanId: servicePlanId,
      );
      if (model.id > 0 && model.planDatetime.trim().isNotEmpty) {
        return model;
      }
    }
    return null;
  }

  static Future<ApiResponse> updateServicePlan({
    required String randevuBaseUrl,
    required int servicePlanId,
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final t = token ?? await JwtStorageService.getToken();
    final urls = _servicePlanByIdUrls(randevuBaseUrl, servicePlanId);
    ApiResponse last = const ApiResponse(
      statusCode: 0,
      body: null,
      isSuccess: false,
    );
    for (final url in urls) {
      last = await RequestUtil.putJson(url, body: body, token: t);
      if (last.isSuccess) return last;
    }
    return last;
  }

  static Future<ApiResponse> deleteServicePlan({
    required String randevuBaseUrl,
    required int servicePlanId,
    String? token,
  }) async {
    final t = token ?? await JwtStorageService.getToken();
    final urls = _servicePlanByIdUrls(randevuBaseUrl, servicePlanId);
    ApiResponse last = const ApiResponse(
      statusCode: 0,
      body: null,
      isSuccess: false,
    );
    for (final url in urls) {
      last = await RequestUtil.deleteJson(url, token: t);
      if (last.isSuccess) return last;
    }
    return last;
  }
}
