import 'package:e_sport_life/core/extensions/url_slash_extension.dart';

class PotentialCustomerUrlConstants {
  static String createWithReferenceUri =
      "v1/potential-customer/create-with-reference";

  static String getCreateWithReferenceUrl(String potentialCustomerUrl) {
    return potentialCustomerUrl.ensureApiPath().ensureTrailingSlash() + createWithReferenceUri;
  }
}
