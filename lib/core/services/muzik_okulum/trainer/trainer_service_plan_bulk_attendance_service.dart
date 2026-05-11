import 'package:e_sport_life/core/constants/url/randevu_al_url_constants.dart';
import 'package:e_sport_life/core/utils/request_util.dart';

/// Müzik okulu eğitmen paneli — Randevu `v2/me/service-plans/{id}/attendance|burn`
/// (Fitiz toplu yoklama ile aynı sıra ve gövde).
class TrainerServicePlanBulkAttendanceService {
  TrainerServicePlanBulkAttendanceService._();

  static Future<ApiResponse> postAttendanceBulk({
    required String randevuApiBaseUrl,
    required String token,
    required int servicePlanId,
    required String dateYmd,
    required bool trackPayment,
    required List<Map<String, dynamic>> students,
  }) {
    final url = RandevuAlUrlConstants.getV2ServicePlanAttendanceUrl(
      randevuApiBaseUrl,
      servicePlanId,
    );
    return RequestUtil.postJson(
      url,
      token: token,
      body: <String, dynamic>{
        'date': dateYmd,
        'track_payment': trackPayment,
        'students': students,
      },
    );
  }

  static Future<ApiResponse> deleteAttendanceBulk({
    required String randevuApiBaseUrl,
    required String token,
    required int servicePlanId,
    required String dateYmd,
    required bool trackPayment,
    required List<int> userIds,
  }) {
    final url = RandevuAlUrlConstants.getV2ServicePlanAttendanceUrl(
      randevuApiBaseUrl,
      servicePlanId,
    );
    return RequestUtil.deleteJson(
      url,
      token: token,
      body: <String, dynamic>{
        'date': dateYmd,
        'track_payment': trackPayment,
        'user_ids': userIds,
      },
    );
  }

  static Future<ApiResponse> postBurn({
    required String randevuApiBaseUrl,
    required String token,
    required int servicePlanId,
    required String dateYmd,
    required bool trackPayment,
    required List<int> userIds,
    int? memberRegisterId,
  }) {
    final url =
        RandevuAlUrlConstants.getV2ServicePlanBurnUrl(randevuApiBaseUrl, servicePlanId);
    final body = <String, dynamic>{
      'date': dateYmd,
      'track_payment': trackPayment,
      'user_ids': userIds,
    };
    if (memberRegisterId != null) {
      body['member_register_id'] = memberRegisterId;
    }
    return RequestUtil.postJson(url, token: token, body: body);
  }

  static Future<ApiResponse> deleteUnburn({
    required String randevuApiBaseUrl,
    required String token,
    required int servicePlanId,
    required String dateYmd,
    required bool trackPayment,
    required List<int> userIds,
  }) {
    final url =
        RandevuAlUrlConstants.getV2ServicePlanBurnUrl(randevuApiBaseUrl, servicePlanId);
    return RequestUtil.deleteJson(
      url,
      token: token,
      body: <String, dynamic>{
        'date': dateYmd,
        'track_payment': trackPayment,
        'user_ids': userIds,
      },
    );
  }
}
