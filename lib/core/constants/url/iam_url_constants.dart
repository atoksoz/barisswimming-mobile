import 'package:e_sport_life/core/extensions/url_slash_extension.dart';

class IamUrlConstants {
  static String iamBaseUrl = "https://iam.manasteknoloji.net";
  static String iamApiUri = "api";
  static String iamCheckTokenIsValidUri = "v1/validation/check-token-is-valid";
  static String emailVerificationResendUri = "v1/email-verification/resend";

  static String getCheckTokenIsValidUrl() {
    return iamBaseUrl.ensureTrailingSlash() +
        iamApiUri.ensureTrailingSlash() +
        iamCheckTokenIsValidUri;
  }

  static String getEmailVerificationResendUrl() {
    return iamBaseUrl.ensureTrailingSlash() +
        iamApiUri.ensureTrailingSlash() +
        emailVerificationResendUri;
  }
}

//
