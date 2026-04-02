import 'package:e_sport_life/core/extensions/url_slash_extension.dart';

class SecurityCodeUrlConstants {
  static String createAndGetSecurityCodeUri =
      "v1/security-code/create-and-get-security-code";

  static String useSecurityCodeUri =
      "v1/security-code/use-security-code";

  static String getcreateAndGetSecurityCodeUriUrl(
      String baseUrl, String applicationId) {
    return baseUrl.ensureTrailingSlash() +
        createAndGetSecurityCodeUri +
        "?application_id=" +
        applicationId;
  }

  static String getUseSecurityCodeUrl(
      String baseUrl, String applicationId, String securityCode, String userId) {
    return '${baseUrl.ensureTrailingSlash()}$useSecurityCodeUri'
        '?application_id=$applicationId&security_code=$securityCode&user_id=$userId';
  }
}
