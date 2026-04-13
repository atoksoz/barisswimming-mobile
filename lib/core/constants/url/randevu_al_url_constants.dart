import 'package:e_sport_life/core/extensions/url_slash_extension.dart';

class RandevuAlUrlConstants {
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
  static String trainerVoteUri = "v1/trainer/vote";
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

  static String getTrainerVoteUrl(String baseUrl) {
    return baseUrl.ensureApiPath().ensureTrailingSlash() + trainerVoteUri;
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

  // ─── Mobile (Trainer/Moderator/Admin) ───

  static String _mobile(String baseUrl) =>
      baseUrl.ensureApiPath().ensureTrailingSlash() + 'mobile/';

  // Service Plans (Grup Dersleri)
  static String getMobileServicePlansUrl(String baseUrl) =>
      '${_mobile(baseUrl)}service-plans';

  static String getMobileServicePlanCalendarUrl(String baseUrl) =>
      '${_mobile(baseUrl)}service-plans/calendar';

  static String getMobileServicePlanUrl(String baseUrl, int id) =>
      '${_mobile(baseUrl)}service-plans/$id';

  static String getMobileServicePlanCancelUrl(String baseUrl, int id) =>
      '${_mobile(baseUrl)}service-plans/$id/cancel';

  static String getMobileServicePlanUncancelUrl(String baseUrl, int id) =>
      '${_mobile(baseUrl)}service-plans/$id/uncancel';

  // Enrollment
  static String getMobileEnrollmentsUrl(String baseUrl, int servicePlanId) =>
      '${_mobile(baseUrl)}service-plans/$servicePlanId/enrollments';

  static String getMobileEnrollmentDeleteUrl(
          String baseUrl, int servicePlanId, int enrollmentId) =>
      '${_mobile(baseUrl)}service-plans/$servicePlanId/enrollments/$enrollmentId';

  static String getMobileEligibleMembersUrl(
          String baseUrl, int servicePlanId) =>
      '${_mobile(baseUrl)}service-plans/$servicePlanId/eligible-members';

  // Yoklama
  static String getMobileAttendanceUrl(String baseUrl, int servicePlanId) =>
      '${_mobile(baseUrl)}service-plans/$servicePlanId/attendance';

  // Hak Düşümü
  static String getMobileBurnUrl(String baseUrl, int servicePlanId) =>
      '${_mobile(baseUrl)}service-plans/$servicePlanId/burn';

  // PT Planları
  static String getMobilePtPlansUrl(String baseUrl) =>
      '${_mobile(baseUrl)}pt-service-now-plans';

  static String getMobilePtCalendarUrl(String baseUrl) =>
      '${_mobile(baseUrl)}pt-service-now-plans/calendar';

  static String getMobilePtPlanUrl(String baseUrl, int id) =>
      '${_mobile(baseUrl)}pt-service-now-plans/$id';

  static String getMobilePtPlanCancelUrl(String baseUrl, int id) =>
      '${_mobile(baseUrl)}pt-service-now-plans/$id/cancel';

  // Rezervasyonlar
  static String getMobileReservationsUrl(String baseUrl) =>
      '${_mobile(baseUrl)}reservations';

  static String getMobileReservationUrl(String baseUrl, int id) =>
      '${_mobile(baseUrl)}reservations/$id';

  static String getMobileReservationCancelUrl(String baseUrl, int id) =>
      '${_mobile(baseUrl)}reservations/cancel/$id';

  static String getMobileReservationAttendanceUrl(String baseUrl, int id) =>
      '${_mobile(baseUrl)}reservations/$id/attendance';

  // Eğitmenler
  static String getMobileEmployeesUrl(String baseUrl) =>
      '${_mobile(baseUrl)}employees';

  static String getMobileEmployeeUrl(String baseUrl, int id) =>
      '${_mobile(baseUrl)}employees/$id';

  static String getMobileEmployeeLessonsUrl(String baseUrl, int id) =>
      '${_mobile(baseUrl)}employees/$id/lessons';

  // Hizmetler & Ürünler
  static String getMobileServicesUrl(String baseUrl) =>
      '${_mobile(baseUrl)}services';

  static String getMobileProductsUrl(String baseUrl) =>
      '${_mobile(baseUrl)}products';

  // Lokasyonlar
  static String getMobileLocationsUrl(String baseUrl) =>
      '${_mobile(baseUrl)}group-lesson-locations';

  // ─── Trainer Self-Service (v2/me/) ───

  static String _selfService(String baseUrl) =>
      baseUrl.ensureApiPath().ensureTrailingSlash() + 'v2/me/';

  static String getTrainerProfileUrl(String baseUrl) =>
      '${_selfService(baseUrl)}profile';

  static String getTrainerProfileUploadImageUrl(String baseUrl) =>
      '${_selfService(baseUrl)}profile/upload-image';

  static String getTrainerProfileDeleteImageUrl(String baseUrl) =>
      '${_selfService(baseUrl)}profile/image';

  static String getEmailVerificationStatusUrl(String baseUrl) =>
      '${_selfService(baseUrl)}email-verification-status';

  static String getResendEmailVerificationUrl(String baseUrl) =>
      '${_selfService(baseUrl)}resend-email-verification';

  static String getCheckEmailUrl(String baseUrl) =>
      '${_selfService(baseUrl)}check-email';

  static String getChangeEmailUrl(String baseUrl) =>
      '${_selfService(baseUrl)}change-email';

  static String getCheckPhoneUrl(String baseUrl) =>
      '${_selfService(baseUrl)}check-phone';

  static String getChangePhoneUrl(String baseUrl) =>
      '${_selfService(baseUrl)}change-phone';

  static String getChangePasswordUrl(String baseUrl) =>
      '${_selfService(baseUrl)}change-password';

  // ─── Trainer Dashboard ───

  static String getTodaySummaryUrl(String baseUrl) =>
      '${_selfService(baseUrl)}today-summary';

  // ─── Member Self-Service ───

  static String getMyTodayLessonCountUrl(String baseUrl) =>
      '${_selfService(baseUrl)}today-lesson-count';

  static String getMyScheduleUrl(String baseUrl) =>
      '${_selfService(baseUrl)}my-schedule';

  // ─── Müzik Okulu Dashboard (birleşik) ───

  static String getMyMuzikOkulumHomeDashboardUrl(String baseUrl) =>
      '${_selfService(baseUrl)}muzik-okulum/home-dashboard';

  // ─── Employee Professions ───

  static String getEmployeeProfessionsUrl(String baseUrl) =>
      baseUrl.ensureApiPath().ensureTrailingSlash() + 'v2/employee-professions';

  // ─── Yoklama / Hak Düşümü ───

  static String getAttendanceTakeUrl(String baseUrl) =>
      '${_selfService(baseUrl)}attendance/take';

  static String getAttendanceUndoUrl(String baseUrl, int id) =>
      '${_selfService(baseUrl)}attendance/$id';

  static String getAttendanceMemberDetailUrl(String baseUrl, int memberId) =>
      '${_selfService(baseUrl)}attendance/member/$memberId';

  static String getAttendanceMemberPackagesUrl(String baseUrl, int memberId) =>
      '${_selfService(baseUrl)}attendance/member/$memberId/active-packages';

  static String getAttendanceMemberHistoryUrl(String baseUrl, int memberId) =>
      '${_selfService(baseUrl)}attendance/member/$memberId/history';

  static String getAttendanceMemberByCardUrl(String baseUrl, String cardNumber) =>
      '${_selfService(baseUrl)}attendance/member-by-card?card_number=$cardNumber';

}
