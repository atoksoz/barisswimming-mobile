import 'package:e_sport_life/core/extensions/url_slash_extension.dart';

class ApiHamamSpaUrlConstants {
  static String addSuggestionComplaintUri = "v1/suggestion-complaints";
  static String getSuggestionComplaintUri = "v1/suggestion-complaints";
  static String deviceRegisterUri = "v1/mobile/device/register";
  static String deviceVerifyUri = "v1/mobile/device/verify";
  static String mobileApplicationSettingsUri = "v1/mobile-application/settings";
  static String announcementsLatestUri = "v1/announcements/latest";
  static String announcementsIndexUri = "v1/announcements";
  static String announcementsShowUri = "v1/announcements";
  static String facilityDetailsUri = "v1/facility-details";
  static String myAbilitiesUri = "v2/role-abilities/my";

  static String addSuggestionComplaintUrl(String apiHamamSpaUrl) {
    return apiHamamSpaUrl.ensureApiPath().ensureTrailingSlash() + addSuggestionComplaintUri;
  }

  static String getSuggestionComplaintUrl(String apiHamamSpaUrl) {
    return apiHamamSpaUrl.ensureApiPath().ensureTrailingSlash() + getSuggestionComplaintUri;
  }

  static String getDeviceRegisterUrl(String apiHamamSpaUrl) {
    return apiHamamSpaUrl.ensureApiPath().ensureTrailingSlash() + deviceRegisterUri;
  }

  static String getDeviceVerifyUrl(String apiHamamSpaUrl,
      {required String memberId, required String deviceUuid}) {
    final base = apiHamamSpaUrl.ensureApiPath().ensureTrailingSlash() + deviceVerifyUri;
    return '$base?member_id=$memberId&device_uuid=$deviceUuid';
  }

  static String getMobileApplicationSettingsUrl(String apiHamamSpaUrl) {
    return apiHamamSpaUrl.ensureApiPath().ensureTrailingSlash() + mobileApplicationSettingsUri;
  }

  static String getAnnouncementsLatestUrl(String apiHamamSpaUrl) {
    return apiHamamSpaUrl.ensureApiPath().ensureTrailingSlash() + announcementsLatestUri;
  }

  static String getAnnouncementsIndexUrl(String apiHamamSpaUrl) {
    return apiHamamSpaUrl.ensureApiPath().ensureTrailingSlash() + announcementsIndexUri;
  }

  static String getAnnouncementsShowUrl(String apiHamamSpaUrl, int announcementId) {
    return apiHamamSpaUrl.ensureApiPath().ensureTrailingSlash() + 
           announcementsShowUri.ensureTrailingSlash() + 
           announcementId.toString();
  }

  static String getFacilityDetailsUrl(String apiHamamSpaUrl) {
    return apiHamamSpaUrl.ensureApiPath().ensureTrailingSlash() + facilityDetailsUri;
  }

  static String getMyAbilitiesUrl(String apiHamamSpaUrl,
      {String platform = 'mobile'}) {
    return '${apiHamamSpaUrl.ensureApiPath().ensureTrailingSlash()}$myAbilitiesUri?platform=$platform';
  }

  // ─── V2 (Trainer/Moderator/Admin) ───

  static String getMemberDetailUrl(String apiUrl, int memberId) =>
      '${apiUrl.ensureApiPath().ensureTrailingSlash()}v2/members/$memberId';

  static String getMemberEligiblePackagesUrl(String apiUrl, int memberId) =>
      '${apiUrl.ensureApiPath().ensureTrailingSlash()}v2/members/$memberId/eligible-packages';

  static String getMemberPackagesUrl(String apiUrl, int memberId) =>
      '${apiUrl.ensureApiPath().ensureTrailingSlash()}v2/members/$memberId/packages';

  static String getMemberByCardUrl(String apiUrl, String cardNumber) =>
      '${apiUrl.ensureApiPath().ensureTrailingSlash()}v2/members/by-card?card_number=$cardNumber';

  static String getMemberActionsUrl(
    String apiUrl,
    int memberId, {
    int page = 1,
    int itemsPerPage = 20,
  }) =>
      '${apiUrl.ensureApiPath().ensureTrailingSlash()}v2/members/$memberId/actions?page=$page&itemsPerPage=$itemsPerPage';

  // ─── V2 Member Self-Service (v2/me/) ───

  static String getMyActionsUrl(
    String apiUrl, {
    int page = 1,
    int itemsPerPage = 20,
  }) =>
      '${apiUrl.ensureApiPath().ensureTrailingSlash()}v2/me/actions?page=$page&itemsPerPage=$itemsPerPage';

  static String getDecreaseQuantityUrl(String apiUrl, int memberRegisterId) =>
      '${apiUrl.ensureApiPath().ensureTrailingSlash()}v1/member-register/$memberRegisterId/decrease-remain-quantity';

  static String getIncreaseQuantityUrl(String apiUrl, int memberRegisterId) =>
      '${apiUrl.ensureApiPath().ensureTrailingSlash()}v1/member-register/$memberRegisterId/increase-remain-quantity';

}
