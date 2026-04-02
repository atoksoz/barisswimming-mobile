import 'package:e_sport_life/core/extensions/url_slash_extension.dart';

class SystemApiUrlConstants {
  static const String systemApiBaseUrl = "https://system.manasteknoloji.net";
  static String iamApiUri = "api";
  static String useTokenUri = "v1/token/use";

  static String getSystemApiBaseUrl() {
    return systemApiBaseUrl.ensureTrailingSlash();
  }

  static String getUseTokenUrl(String token) {
    return systemApiBaseUrl.ensureTrailingSlash() +
        iamApiUri.ensureTrailingSlash() +
        useTokenUri +
        "?token=" +
        token;
  }
}
