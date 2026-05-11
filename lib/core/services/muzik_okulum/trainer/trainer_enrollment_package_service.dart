import 'dart:convert';

import 'package:e_sport_life/core/constants/url/randevu_al_url_constants.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/data/model/muzik_okulum/trainer/trainer_enrollment_package_option_model.dart';

/// Randevu eğitmen — derse kayıtlı paket seçenekleri ve güncelleme.
class TrainerEnrollmentPackageService {
  TrainerEnrollmentPackageService._();

  static Future<TrainerEnrollmentPackageOptionsOutputModel?> fetchPackageOptions({
    required String baseUrl,
    required String token,
    required int planId,
    required int enrollmentId,
  }) async {
    final url = RandevuAlUrlConstants.getV2TrainerEnrollmentPackageOptionsUrl(
      baseUrl,
      planId: planId,
      enrollmentId: enrollmentId,
    );
    final res = await RequestUtil.getJson(url, token: token);
    // ignore: avoid_print
    print(
      '[TrainerEnrollmentPackage] GET package-options\n'
      '  url: $url\n'
      '  statusCode: ${res.statusCode} isSuccess: ${res.isSuccess}\n'
      '  message: ${res.message}\n'
      '  body: ${_jsonForLog(res.body)}',
    );
    if (!res.isSuccess) return null;
    final m = res.outputMap;
    if (m == null) {
      // ignore: avoid_print
      print('[TrainerEnrollmentPackage] outputMap null (raw body yukarıda).');
      return null;
    }
    final model = TrainerEnrollmentPackageOptionsOutputModel.fromJson(m);
    // ignore: avoid_print
    print(
      '[TrainerEnrollmentPackage] parsed: memberId=${model.memberId} '
      'currentRegisterId=${model.currentMemberRegisterId} '
      'optionsCount=${model.options.length} '
      'allowedProductIds=${model.allowedProductPackageIds}',
    );
    return model;
  }

  static Future<bool> updateEnrollmentPackage({
    required String baseUrl,
    required String token,
    required int planId,
    required int enrollmentId,
    required int memberRegisterId,
  }) async {
    final url = RandevuAlUrlConstants.getV2TrainerEnrollmentPackageUrl(
      baseUrl,
      planId: planId,
      enrollmentId: enrollmentId,
    );
    final res = await RequestUtil.patchJson(
      url,
      token: token,
      body: {'member_register_id': memberRegisterId},
    );
    // ignore: avoid_print
    print(
      '[TrainerEnrollmentPackage] PATCH package\n'
      '  url: $url\n'
      '  body: {member_register_id: $memberRegisterId}\n'
      '  statusCode: ${res.statusCode} isSuccess: ${res.isSuccess}\n'
      '  message: ${res.message}\n'
      '  body: ${_jsonForLog(res.body)}',
    );
    return res.isSuccess;
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
