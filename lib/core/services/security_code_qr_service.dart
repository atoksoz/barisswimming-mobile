import 'dart:convert';

import 'package:e_sport_life/core/constants/url/security_code_url_constants.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/utils/request_util.dart';

class SecurityCodeQrResult {
  final bool success;
  final String? qrData;
  final String? errorMessage;

  const SecurityCodeQrResult._({
    required this.success,
    this.qrData,
    this.errorMessage,
  });

  factory SecurityCodeQrResult.ok(String qrData) =>
      SecurityCodeQrResult._(success: true, qrData: qrData);

  factory SecurityCodeQrResult.error(String message) =>
      SecurityCodeQrResult._(success: false, errorMessage: message);
}

class SecurityCodeQrService {
  /// Security-code API'sine istek atarak QR verisi oluşturur.
  /// Üye QR ekranı ve personel QR ekranı bu metodu ortak kullanır.
  static Future<SecurityCodeQrResult> generateQrCode({
    required String securityCodeBaseUrl,
    required String applicationId,
  }) async {
    try {
      final token = await JwtStorageService.getToken();
      if (token == null || token.isEmpty) {
        return SecurityCodeQrResult.error('Oturum bilgisi bulunamadı');
      }

      final url = SecurityCodeUrlConstants.getcreateAndGetSecurityCodeUriUrl(
        securityCodeBaseUrl,
        applicationId,
      );

      final response = await RequestUtil.get(url, token: token);
      if (response == null) {
        return SecurityCodeQrResult.error(
            'Güvenlik kodu oluşturma servisine ulaşılamıyor');
      }

      final Map<String, dynamic> json = jsonDecode(response.body);

      if (json['output'] == false || json['output'] == null) {
        final message =
            json['extras']?.toString() ?? 'QR kod oluşturulamadı';
        return SecurityCodeQrResult.error(message);
      }

      return SecurityCodeQrResult.ok(json['output'].toString());
    } catch (e) {
      return SecurityCodeQrResult.error(
          'Güvenlik kodu oluşturma servisine ulaşılamıyor');
    }
  }
}
