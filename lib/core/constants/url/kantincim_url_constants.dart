import 'package:e_sport_life/core/extensions/url_slash_extension.dart';

class KantincimUrlConstants {
  static String openOrdersExtractUri = "v1/member/open-orders-extract";
  static String mobileSalesProductUri = "v1/qr-menu/mobile-sales/get-products";
  static String loyaltyBalanceUri = "v1/member/loyalty/balance";
  static String loyaltyLogsUri = "v1/member/loyalty/logs";
  static String walletBalanceUri = "v1/member/wallet/balance";
  static String walletLogsUri = "v1/member/wallet/logs";

  static String getOpenOrdersExtractUrl(String hamamSpaUrl) {
    return hamamSpaUrl.ensureApiPath().ensureTrailingSlash() + openOrdersExtractUri;
  }

  static String getMobileSalesProductUrl(String hamamSpaUrl) {
    return hamamSpaUrl.ensureApiPath().ensureTrailingSlash() + mobileSalesProductUri;
  }

  static String getLoyaltyBalanceUrl(String kantincimUrl) {
    return kantincimUrl.ensureApiPath().ensureTrailingSlash() + loyaltyBalanceUri;
  }

  static String getLoyaltyLogsUrl(String kantincimUrl) {
    return kantincimUrl.ensureApiPath().ensureTrailingSlash() + loyaltyLogsUri;
  }

  static String getWalletBalanceUrl(String kantincimUrl) {
    return kantincimUrl.ensureApiPath().ensureTrailingSlash() + walletBalanceUri;
  }

  static String getWalletLogsUrl(String kantincimUrl) {
    return kantincimUrl.ensureApiPath().ensureTrailingSlash() + walletLogsUri;
  }
}
