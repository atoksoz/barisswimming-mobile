import 'dart:convert';

import 'package:e_sport_life/core/constants/url/randevu_al_url_constants.dart';
import 'package:e_sport_life/core/utils/request_util.dart';

/// Randevu `routes/api_v2_trainer.php` — `GET /api/v2/me/employee/...`
/// Oturumdaki eğitmen (JWT `user.id` = `employees.id`); istemci başka id göndermez.
class TrainerSelfEmployeeService {
  TrainerSelfEmployeeService._();

  static Future<ApiResponse> fetchWeeklyStats({
    required String randevuApiUrl,
    required String startDate,
    required String endDate,
    String? token,
  }) {
    final base =
        RandevuAlUrlConstants.getV2MeTrainerSelfEmployeeStatsUrl(randevuApiUrl);
    final url =
        '$base?start_date=${Uri.encodeQueryComponent(startDate)}&end_date=${Uri.encodeQueryComponent(endDate)}';
    return RequestUtil.getJson(url, token: token);
  }

  static Future<ApiResponse> fetchLessons({
    required String randevuApiUrl,
    required String start,
    required String end,
    String? token,
  }) async {
    // Randevu api_v2_trainer — GET …/v2/me/employee/lessons
    final base =
        RandevuAlUrlConstants.getV2MeTrainerSelfEmployeeLessonsUrl(randevuApiUrl);
    final url =
        '$base?start=${Uri.encodeQueryComponent(start)}&end=${Uri.encodeQueryComponent(end)}';
    final res = await RequestUtil.getJson(url, token: token);
    // ignore: avoid_print
    print(
      '[TrainerSelfEmployee] GET v2/me/employee/lessons\n'
      '  url: $url\n'
      '  statusCode: ${res.statusCode} isSuccess: ${res.isSuccess}\n'
      '  message: ${res.message}\n'
      '  body: ${_jsonForLog(res.body)}',
    );
    return res;
  }

  static String _jsonForLog(dynamic body) {
    if (body == null) return 'null';
    if (body is Map || body is List) {
      try {
        return jsonEncode(body);
      } catch (_) {
        return body.toString();
      }
    }
    return body.toString();
  }
}
