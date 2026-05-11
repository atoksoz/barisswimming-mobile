import 'package:e_sport_life/core/extensions/url_slash_extension.dart';

import 'randevu_al_trainer_url_constants.dart';

/// Randevu API — üye / rezervasyon v1 ve üye `v2/me/` self-service.
///
/// Eğitmen ve mobil staff uçları: [RandevuAlTrainerUrlConstants].
class RandevuAlUrlConstants {
  RandevuAlUrlConstants._();

  static String getAllTrainersUri = "v1/trainer/get-all-trainers";
  static String myResarvationNowListUri =
      "v1/member/service-now-plan/get-my-resarvation-now-list2";
  static String cancelResarvationUri =
      "v1/member/service-now-plan/cancel-resarvation-with-service-and-member-id?id=";
  static String serviceNowPlanGetByDateNumberUri =
      "v1/member/service-now-plan/get-by-date-number?day_number=";
  static String serviceNowPlanGetFreeTimesForResarvationUri =
      "v1/member/service-now-plan/get-free-times-for-resarvation-now-by-date-number?";
  static String ptGetFreeTimesUri =
      "v1/member/service-now-plan/get-pt-free-times?";
  static String serviceNowPlanAddResarvationUri =
      "v1/member/service-now-plan/add-resarvation";
  static String groupLessonsUri = "v1/member/group-lessons";
  static String groupLessonByDayNumberUri =
      "v1/member/group-lessons/get-by-date-number?day_number=";
  static String groupLessonResarvationsUri =
      "v1/member/group-lessons/get-my-resarvations";
  static String addGroupLessonResarvationUri =
      "v1/member/group-lessons/add-resarvation";
  static String cancelGroupLessonResarvationUri =
      "v1/member/group-lessons/cancel-resarvation-with-service-and-member-id?service_plan_id=";

  static String getAllTrainersUrl(String baseUrl) {
    return baseUrl.ensureApiPath().ensureTrailingSlash() + getAllTrainersUri;
  }

  static String getMyResarvationNowListUrl(String baseUrl) {
    return baseUrl.ensureApiPath().ensureTrailingSlash() + myResarvationNowListUri;
  }

  static String getCancelResarvationNowUrl(String baseUrl, String id) {
    return baseUrl.ensureApiPath().ensureTrailingSlash() + cancelResarvationUri + id;
  }

  static String getServiceNowPlanGetByDateNumberUrl(
      String baseUrl, String day) {
    return baseUrl.ensureApiPath().ensureTrailingSlash() +
        serviceNowPlanGetByDateNumberUri +
        day;
  }

  static String getServiceNowPlanGetFreeTimesForResarvationUrl(
      String baseUrl, String day, String service_now_plan_id) {
    return baseUrl.ensureApiPath().ensureTrailingSlash() +
        serviceNowPlanGetFreeTimesForResarvationUri +
        "day_number=" +
        day +
        "&service_now_plan_id=" +
        service_now_plan_id;
  }

  static String getPtFreeTimesUrl(
      String baseUrl, String day, String employee_id) {
    return baseUrl.ensureApiPath().ensureTrailingSlash() +
        ptGetFreeTimesUri +
        "day_number=" +
        day +
        "&employee_id=" +
        employee_id;
  }

  static String getAddServiceNowPlanAddResarvationUrl(String baseUrl) {
    return baseUrl.ensureApiPath().ensureTrailingSlash() + serviceNowPlanAddResarvationUri;
  }

  static String getGroupLessonUrl(String baseUrl) {
    return baseUrl.ensureApiPath().ensureTrailingSlash() + groupLessonsUri;
  }

  static String getGroupLessonByDayNumberUrl(String baseUrl, int dayNumber) {
    return baseUrl.ensureApiPath().ensureTrailingSlash() +
        groupLessonByDayNumberUri +
        dayNumber.toString();
  }

  static String getGroupLessonResarvationsUrl(String baseUrl) {
    return baseUrl.ensureApiPath().ensureTrailingSlash() + groupLessonResarvationsUri;
  }

  static String getAddResarvationUrl(String baseUrl) {
    return baseUrl.ensureApiPath().ensureTrailingSlash() + addGroupLessonResarvationUri;
  }

  static String cancelGroupLessonResarvationUrl(
      String baseUrl, int servicePlanId) {
    return baseUrl.ensureTrailingSlash() +
        cancelGroupLessonResarvationUri +
        servicePlanId.toString();
  }

  // ─── Member Self-Service (`v2/me/`) ───

  static String _selfService(String baseUrl) =>
      baseUrl.ensureApiPath().ensureTrailingSlash() + 'v2/me/';

  static String getMyTodayLessonCountUrl(String baseUrl) =>
      '${_selfService(baseUrl)}today-lesson-count';

  static String getMyScheduleUrl(String baseUrl) =>
      '${_selfService(baseUrl)}my-schedule';

  static String getMyMuzikOkulumHomeDashboardUrl(String baseUrl) =>
      '${_selfService(baseUrl)}muzik-okulum/home-dashboard';

  /// Üye JWT — havuz / grup dersi lokasyonları (`routes/api_v2_member.php`).
  static String getMemberPoolLocationsUrl(String baseUrl) =>
      '${_selfService(baseUrl)}pool-locations';

  // ─── Eğitmen / mobil staff — delegasyon [RandevuAlTrainerUrlConstants] ───

  static String getTrainerVoteUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getTrainerVoteUrl(baseUrl);

  static String getMobileServicePlansUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getMobileServicePlansUrl(baseUrl);

  static String getMobileServicePlanCalendarUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getMobileServicePlanCalendarUrl(baseUrl);

  static String getMobileServicePlanUrl(String baseUrl, int id) =>
      RandevuAlTrainerUrlConstants.getMobileServicePlanUrl(baseUrl, id);

  static String getMobileServicePlanCancelUrl(String baseUrl, int id) =>
      RandevuAlTrainerUrlConstants.getMobileServicePlanCancelUrl(baseUrl, id);

  static String getMobileServicePlanUncancelUrl(String baseUrl, int id) =>
      RandevuAlTrainerUrlConstants.getMobileServicePlanUncancelUrl(baseUrl, id);

  static String getMobileEnrollmentsUrl(String baseUrl, int servicePlanId) =>
      RandevuAlTrainerUrlConstants.getMobileEnrollmentsUrl(baseUrl, servicePlanId);

  static String getMobileEnrollmentDeleteUrl(
          String baseUrl, int servicePlanId, int enrollmentId) =>
      RandevuAlTrainerUrlConstants.getMobileEnrollmentDeleteUrl(
          baseUrl, servicePlanId, enrollmentId);

  static String getMobileEligibleMembersUrl(
          String baseUrl, int servicePlanId) =>
      RandevuAlTrainerUrlConstants.getMobileEligibleMembersUrl(
          baseUrl, servicePlanId);

  static String getMobileAttendanceUrl(String baseUrl, int servicePlanId) =>
      RandevuAlTrainerUrlConstants.getMobileAttendanceUrl(baseUrl, servicePlanId);

  static String getMobileBurnUrl(String baseUrl, int servicePlanId) =>
      RandevuAlTrainerUrlConstants.getMobileBurnUrl(baseUrl, servicePlanId);

  static String getMobilePtPlansUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getMobilePtPlansUrl(baseUrl);

  static String getMobilePtCalendarUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getMobilePtCalendarUrl(baseUrl);

  static String getMobilePtPlanUrl(String baseUrl, int id) =>
      RandevuAlTrainerUrlConstants.getMobilePtPlanUrl(baseUrl, id);

  static String getMobilePtPlanCancelUrl(String baseUrl, int id) =>
      RandevuAlTrainerUrlConstants.getMobilePtPlanCancelUrl(baseUrl, id);

  static String getMobileReservationsUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getMobileReservationsUrl(baseUrl);

  static String getMobileReservationUrl(String baseUrl, int id) =>
      RandevuAlTrainerUrlConstants.getMobileReservationUrl(baseUrl, id);

  static String getMobileReservationCancelUrl(String baseUrl, int id) =>
      RandevuAlTrainerUrlConstants.getMobileReservationCancelUrl(baseUrl, id);

  static String getMobileReservationAttendanceUrl(String baseUrl, int id) =>
      RandevuAlTrainerUrlConstants.getMobileReservationAttendanceUrl(baseUrl, id);

  static String getMobileEmployeesUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getMobileEmployeesUrl(baseUrl);

  static String getMobileEmployeeUrl(String baseUrl, int id) =>
      RandevuAlTrainerUrlConstants.getMobileEmployeeUrl(baseUrl, id);

  static String getMobileEmployeeLessonsUrl(String baseUrl, int id) =>
      RandevuAlTrainerUrlConstants.getMobileEmployeeLessonsUrl(baseUrl, id);

  static String getMobileEmployeeStatsUrl(String baseUrl, int id) =>
      RandevuAlTrainerUrlConstants.getMobileEmployeeStatsUrl(baseUrl, id);

  static String getV2MeTrainerSelfEmployeeStatsUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getV2MeTrainerSelfEmployeeStatsUrl(baseUrl);

  static String getV2MeTrainerSelfEmployeeLessonsUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getV2MeTrainerSelfEmployeeLessonsUrl(baseUrl);

  static String getMobileServicesUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getMobileServicesUrl(baseUrl);

  static String getMobileProductsUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getMobileProductsUrl(baseUrl);

  static String getMobileLocationsUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getMobileLocationsUrl(baseUrl);

  static String getTrainerProfileUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getTrainerProfileUrl(baseUrl);

  static String getTrainerProfileUploadImageUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getTrainerProfileUploadImageUrl(baseUrl);

  static String getTrainerProfileDeleteImageUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getTrainerProfileDeleteImageUrl(baseUrl);

  static String getEmailVerificationStatusUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getEmailVerificationStatusUrl(baseUrl);

  static String getResendEmailVerificationUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getResendEmailVerificationUrl(baseUrl);

  static String getCheckEmailUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getCheckEmailUrl(baseUrl);

  static String getChangeEmailUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getChangeEmailUrl(baseUrl);

  static String getCheckPhoneUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getCheckPhoneUrl(baseUrl);

  static String getChangePhoneUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getChangePhoneUrl(baseUrl);

  static String getChangePasswordUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getChangePasswordUrl(baseUrl);

  static String getTodaySummaryUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getTodaySummaryUrl(baseUrl);

  static String getV2ServicePlansCalendarUrl(
    String baseUrl, {
    required String start,
    required String end,
    bool includeDeleted = false,
  }) =>
      RandevuAlTrainerUrlConstants.getV2ServicePlansCalendarUrl(
        baseUrl,
        start: start,
        end: end,
        includeDeleted: includeDeleted,
      );

  static String getV2ServicePlansRootUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getV2ServicePlansRootUrl(baseUrl);

  static String getV2ServicePlanByIdUrl(String baseUrl, int id) =>
      RandevuAlTrainerUrlConstants.getV2ServicePlanByIdUrl(baseUrl, id);

  static String getV2ServicePlanAttendanceUrl(String baseUrl, int servicePlanId) =>
      RandevuAlTrainerUrlConstants.getV2ServicePlanAttendanceUrl(
          baseUrl, servicePlanId);

  static String getV2ServicePlanBurnUrl(String baseUrl, int servicePlanId) =>
      RandevuAlTrainerUrlConstants.getV2ServicePlanBurnUrl(baseUrl, servicePlanId);

  static String getV2TrainerEnrollmentPackageOptionsUrl(
    String baseUrl, {
    required int planId,
    required int enrollmentId,
  }) =>
      RandevuAlTrainerUrlConstants.getV2TrainerEnrollmentPackageOptionsUrl(
        baseUrl,
        planId: planId,
        enrollmentId: enrollmentId,
      );

  static String getV2TrainerEnrollmentPackageUrl(
    String baseUrl, {
    required int planId,
    required int enrollmentId,
  }) =>
      RandevuAlTrainerUrlConstants.getV2TrainerEnrollmentPackageUrl(
        baseUrl,
        planId: planId,
        enrollmentId: enrollmentId,
      );

  static String getV2ServicesUrl(String baseUrl, {String? applicationType}) =>
      RandevuAlTrainerUrlConstants.getV2ServicesUrl(baseUrl,
          applicationType: applicationType);

  static String getV2GroupLessonLocationsUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getV2GroupLessonLocationsUrl(baseUrl);

  static String getEmployeeProfessionsUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getEmployeeProfessionsUrl(baseUrl);

  static String getAttendanceTakeUrl(String baseUrl) =>
      RandevuAlTrainerUrlConstants.getAttendanceTakeUrl(baseUrl);

  static String getAttendanceUndoUrl(String baseUrl, int id) =>
      RandevuAlTrainerUrlConstants.getAttendanceUndoUrl(baseUrl, id);

  static String getAttendanceMemberDetailUrl(String baseUrl, int memberId) =>
      RandevuAlTrainerUrlConstants.getAttendanceMemberDetailUrl(
          baseUrl, memberId);

  static String getAttendanceMemberPackagesUrl(String baseUrl, int memberId) =>
      RandevuAlTrainerUrlConstants.getAttendanceMemberPackagesUrl(
          baseUrl, memberId);

  static String getAttendanceMemberHistoryUrl(String baseUrl, int memberId) =>
      RandevuAlTrainerUrlConstants.getAttendanceMemberHistoryUrl(
          baseUrl, memberId);

  static String getAttendanceMemberByCardUrl(
          String baseUrl, String cardNumber) =>
      RandevuAlTrainerUrlConstants.getAttendanceMemberByCardUrl(
          baseUrl, cardNumber);
}
