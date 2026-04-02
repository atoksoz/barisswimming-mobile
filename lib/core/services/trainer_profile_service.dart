import 'dart:io';

import 'package:e_sport_life/core/constants/url/randevu_al_url_constants.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/utils/request_util.dart';

class TrainerProfileService {
  static Future<ApiResponse> fetchProfile({
    required String randevuApiUrl,
    String? token,
  }) async {
    final url = RandevuAlUrlConstants.getTrainerProfileUrl(randevuApiUrl);
    return await RequestUtil.getJson(url, token: token);
  }

  static Future<ApiResponse> updateProfile({
    required String randevuApiUrl,
    required Map<String, dynamic> data,
    String? token,
  }) async {
    final url = RandevuAlUrlConstants.getTrainerProfileUrl(randevuApiUrl);
    return await RequestUtil.putJson(url, body: data, token: token);
  }

  static Future<ApiResponse> uploadImage({
    required String randevuApiUrl,
    required File imageFile,
    String? token,
  }) async {
    final t = token ?? await JwtStorageService.getToken();
    final url = RandevuAlUrlConstants.getTrainerProfileUploadImageUrl(randevuApiUrl);
    final response = await RequestUtil.postMultipart(
      url,
      file: imageFile,
      token: t,
      fieldName: 'image',
    );
    return RequestUtil.parseResponse(response);
  }

  static Future<ApiResponse> deleteImage({
    required String randevuApiUrl,
    String? token,
  }) async {
    final url = RandevuAlUrlConstants.getTrainerProfileDeleteImageUrl(randevuApiUrl);
    return await RequestUtil.deleteJson(url, token: token);
  }

  static Future<bool> checkEmailVerified({
    required String randevuApiUrl,
    String? token,
  }) async {
    final url = RandevuAlUrlConstants.getEmailVerificationStatusUrl(randevuApiUrl);
    final response = await RequestUtil.getJson(url, token: token);
    if (response.isSuccess && response.outputMap != null) {
      return response.outputMap!['email_verified'] == true;
    }
    return false;
  }

  static Future<ApiResponse> resendEmailVerification({
    required String randevuApiUrl,
    String? token,
  }) async {
    final url = RandevuAlUrlConstants.getResendEmailVerificationUrl(randevuApiUrl);
    return await RequestUtil.postJson(url, token: token);
  }

  static Future<ApiResponse> checkEmail({
    required String randevuApiUrl,
    required String email,
    String? token,
  }) async {
    final url = RandevuAlUrlConstants.getCheckEmailUrl(randevuApiUrl);
    return await RequestUtil.postJson(url, body: {'email': email}, token: token);
  }

  static Future<ApiResponse> changeEmail({
    required String randevuApiUrl,
    required String email,
    String? token,
  }) async {
    final url = RandevuAlUrlConstants.getChangeEmailUrl(randevuApiUrl);
    return await RequestUtil.putJson(url, body: {'email': email}, token: token);
  }

  static Future<ApiResponse> checkPhone({
    required String randevuApiUrl,
    required String phone,
    String? token,
  }) async {
    final url = RandevuAlUrlConstants.getCheckPhoneUrl(randevuApiUrl);
    return await RequestUtil.postJson(url, body: {'phone': phone}, token: token);
  }

  static Future<ApiResponse> changePhone({
    required String randevuApiUrl,
    required String phone,
    String? token,
  }) async {
    final url = RandevuAlUrlConstants.getChangePhoneUrl(randevuApiUrl);
    return await RequestUtil.putJson(url, body: {'phone': phone}, token: token);
  }

  static Future<ApiResponse> changePassword({
    required String randevuApiUrl,
    required String currentPassword,
    required String newPassword,
    String? token,
  }) async {
    final url = RandevuAlUrlConstants.getChangePasswordUrl(randevuApiUrl);
    return await RequestUtil.putJson(url, body: {
      'password': currentPassword,
      'new_password': newPassword,
    }, token: token);
  }

  /// Uygulama tipine göre meslek key listesini döndürür.
  static Future<List<String>> fetchProfessions({
    required String randevuApiUrl,
    String? token,
  }) async {
    final url = RandevuAlUrlConstants.getEmployeeProfessionsUrl(randevuApiUrl);
    final response = await RequestUtil.getJson(url, token: token);
    if (response.isSuccess && response.outputList != null) {
      return response.outputList!
          .map((item) => (item['value'] ?? '').toString())
          .where((v) => v.isNotEmpty)
          .toList();
    }
    return [];
  }
}
