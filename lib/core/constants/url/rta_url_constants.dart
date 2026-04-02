import 'package:e_sport_life/core/extensions/url_slash_extension.dart';

class RtaUrlService {
  static String getMobileLauncherUrl(String baseUrl, String firmUuid) {
    return baseUrl.ensureApiPath().ensureTrailingSlash() +
        "v1/mobile-app/get-mobile-launcher-broadcast-items-firm-uuid?firm_uuid=" +
        firmUuid;
  }

  static String getMobileSliderUrl(String baseUrl, String firmUuid) {
    return baseUrl.ensureApiPath().ensureTrailingSlash() +
        "v1/mobile-app/get-mobile-slider-broadcast-items-firm-uuid?firm_uuid=" +
        firmUuid;
  }
}
