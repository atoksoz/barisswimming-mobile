import 'package:e_sport_life/core/extensions/url_slash_extension.dart';

class HamamSpaUrlConstants {
  static String memberDashboardUri = "v1/dashboard/member";
  static String openRoomSummaryUri = "v1/room/get-open-room-summary";
  static String memberTurnstileActionsUri =
      "v1/member/get-member-turnstile-actions";
  static String memberExtractUri = "v1/member/member-extract";
  static String gymMemberRegisterUri = "v1/member/gym-member-registers2";
  static String massageMemberRegisterUri = "v1/member/massage-member-registers";
  static String ptMemberRegisterUri = "v1/member/pt-member-registers";
  static String activePtMemberRegisterUri = "v1/member/active-pt-member-registers";
  static String branchMemberRegisterUri = "v1/member/branch-member-registers";
  static String activeBranchMemberRegisterUri = "v1/member/active-branch-member-registers";
  static String electronicClosetSituationUri =
      "v1/room/get-electronic-closet-situations";
  static String openOrdersExtractUri = "v1/member/open-orders-extract";
  static String paymentPlanUri = "v1/member/payment-plan";
  static String timeLimitRightNowUri =
      "v1/member-register/time-limit-right-now";
  static String updateProfilePhotoUri = "v1/member/update-profile-photo";
  static String deleteProfilePhotoUri = "v1/member/delete-profile-photo";
  static String updateMemberInfoUri = "v1/member/update-member-info";
  static String unpaidPaymentPlanUri = "v1/member/payment-plan/unpaid";
  static String memberBalanceUri = "v1/member/balance";

  static String getMemberDashboardDataUrl(String hamamSpaUrl) {
    return hamamSpaUrl.ensureTrailingSlash() +
        memberDashboardUri.ensureApiPath().ensureTrailingSlash();
  }

  static String getOpenRoomSummaryUrl(String hamamSpaUrl) {
    return hamamSpaUrl.ensureApiPath().ensureTrailingSlash() + openRoomSummaryUri;
  }

  static String memberTurnstileActionsUrl(String hamamSpaUrl) {
    return hamamSpaUrl.ensureApiPath().ensureTrailingSlash() + memberTurnstileActionsUri;
  }

  static String getMemberExtractsUrl(String hamamSpaUrl) {
    return hamamSpaUrl.ensureApiPath().ensureTrailingSlash() + memberExtractUri;
  }

  static String getGymMemberRegisterUrl(String hamamSpaUrl) {
    return hamamSpaUrl.ensureApiPath().ensureTrailingSlash() + gymMemberRegisterUri;
  }

  static String getMassageMemberRegisterUrl(String hamamSpaUrl) {
    return hamamSpaUrl.ensureApiPath().ensureTrailingSlash() + massageMemberRegisterUri;
  }

  static String getPtMemberRegisterUrl(String hamamSpaUrl) {
    return hamamSpaUrl.ensureApiPath().ensureTrailingSlash() + ptMemberRegisterUri;
  }

  static String getActivePtMemberRegisterUrl(String hamamSpaUrl) {
    return hamamSpaUrl.ensureApiPath().ensureTrailingSlash() + activePtMemberRegisterUri;
  }

  static String getBranchMemberRegisterUrl(String hamamSpaUrl) {
    return hamamSpaUrl.ensureTrailingSlash() + branchMemberRegisterUri;
  }

  static String getActiveBranchMemberRegisterUrl(String hamamSpaUrl) {
    return hamamSpaUrl.ensureApiPath().ensureTrailingSlash() + activeBranchMemberRegisterUri;
  }

  static String getElectronicClosetSituationUrl(String hamamSpaUrl) {
    return hamamSpaUrl.ensureApiPath().ensureTrailingSlash() + electronicClosetSituationUri;
  }

  static String getOpenOrdersExtractUrl(String hamamSpaUrl) {
    return hamamSpaUrl.ensureApiPath().ensureTrailingSlash() + openOrdersExtractUri;
  }

  static String getPaymentPlanUrl(String hamamSpaUrl) {
    return hamamSpaUrl.ensureApiPath().ensureTrailingSlash() + paymentPlanUri;
  }

  static String getTimeLimitRightNowUrl(String hamamSpaUrl) {
    return hamamSpaUrl.ensureApiPath().ensureTrailingSlash() + timeLimitRightNowUri;
  }

  static String getUpdateProfilePhotoUrl(String hamamSpaUrl) {
    return hamamSpaUrl.ensureApiPath().ensureTrailingSlash() + updateProfilePhotoUri;
  }

  static String getDeleteProfilePhotoUrl(String hamamSpaUrl) {
    return hamamSpaUrl.ensureTrailingSlash() + deleteProfilePhotoUri;
  }

  static String getUpdateMemberInfoUrl(String hamamSpaUrl) {
    return hamamSpaUrl.ensureApiPath().ensureTrailingSlash() + updateMemberInfoUri;
  }

  static String getUnpaidPaymentPlanUrl(String apiHamamspaUrl) {
    return apiHamamspaUrl.ensureApiPath().ensureTrailingSlash() + unpaidPaymentPlanUri;
  }

  static String getMemberBalanceUrl(String apiHamamspaUrl) {
    return apiHamamspaUrl.ensureApiPath().ensureTrailingSlash() + memberBalanceUri;
  }
}

//
