import 'dart:io';

import 'package:e_sport_life/core/utils/request_util.dart';

class InternetConnectionUtil {
  /// google.com'a ping atarak internet bağlantısını kontrol eder.
  static Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Security-code servisine istek atarak erişilebilirliğini kontrol eder.
  static Future<bool> checkSecurityCodeService(String securityCodeBaseUrl) async {
    try {
      final response = await RequestUtil.get(
        securityCodeBaseUrl,
        timeout: const Duration(seconds: 5),
      );
      return response != null && response.statusCode < 500;
    } catch (e) {
      return false;
    }
  }
}
