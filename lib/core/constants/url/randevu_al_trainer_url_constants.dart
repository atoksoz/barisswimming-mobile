import 'package:e_sport_life/core/extensions/url_slash_extension.dart';

/// Randevu API — eğitmen / mobil staff (`v2/me/…`, `mobile/…`, yoklama) uçları.
///
/// Üye self-service (`my-schedule` vb.) için [RandevuAlUrlConstants].
class RandevuAlTrainerUrlConstants {
  RandevuAlTrainerUrlConstants._();

  static const String _trainerVoteUri = 'v1/trainer/vote';

  static String getTrainerVoteUrl(String baseUrl) =>
      baseUrl.ensureApiPath().ensureTrailingSlash() + _trainerVoteUri;

  // ─── Mobile (Trainer/Moderator/Admin) ───

  static String _mobile(String baseUrl) =>
      baseUrl.ensureApiPath().ensureTrailingSlash() + 'mobile/';

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

  static String getMobileEnrollmentsUrl(String baseUrl, int servicePlanId) =>
      '${_mobile(baseUrl)}service-plans/$servicePlanId/enrollments';

  static String getMobileEnrollmentDeleteUrl(
          String baseUrl, int servicePlanId, int enrollmentId) =>
      '${_mobile(baseUrl)}service-plans/$servicePlanId/enrollments/$enrollmentId';

  static String getMobileEligibleMembersUrl(
          String baseUrl, int servicePlanId) =>
      '${_mobile(baseUrl)}service-plans/$servicePlanId/eligible-members';

  static String getMobileAttendanceUrl(String baseUrl, int servicePlanId) =>
      '${_mobile(baseUrl)}service-plans/$servicePlanId/attendance';

  static String getMobileBurnUrl(String baseUrl, int servicePlanId) =>
      '${_mobile(baseUrl)}service-plans/$servicePlanId/burn';

  static String getMobilePtPlansUrl(String baseUrl) =>
      '${_mobile(baseUrl)}pt-service-now-plans';

  static String getMobilePtCalendarUrl(String baseUrl) =>
      '${_mobile(baseUrl)}pt-service-now-plans/calendar';

  static String getMobilePtPlanUrl(String baseUrl, int id) =>
      '${_mobile(baseUrl)}pt-service-now-plans/$id';

  static String getMobilePtPlanCancelUrl(String baseUrl, int id) =>
      '${_mobile(baseUrl)}pt-service-now-plans/$id/cancel';

  static String getMobileReservationsUrl(String baseUrl) =>
      '${_mobile(baseUrl)}reservations';

  static String getMobileReservationUrl(String baseUrl, int id) =>
      '${_mobile(baseUrl)}reservations/$id';

  static String getMobileReservationCancelUrl(String baseUrl, int id) =>
      '${_mobile(baseUrl)}reservations/cancel/$id';

  static String getMobileReservationAttendanceUrl(String baseUrl, int id) =>
      '${_mobile(baseUrl)}reservations/$id/attendance';

  static String getMobileEmployeesUrl(String baseUrl) =>
      '${_mobile(baseUrl)}employees';

  static String getMobileEmployeeUrl(String baseUrl, int id) =>
      '${_mobile(baseUrl)}employees/$id';

  static String getMobileEmployeeLessonsUrl(String baseUrl, int id) =>
      '${_mobile(baseUrl)}employees/$id/lessons';

  static String getMobileEmployeeStatsUrl(String baseUrl, int id) =>
      '${_mobile(baseUrl)}employees/$id/stats';

  /// Eğitmen JWT (`api_v2_trainer`) — oturumdaki çalışan; URL’de id yok.
  static String getV2MeTrainerSelfEmployeeStatsUrl(String baseUrl) =>
      '${_selfService(baseUrl)}employee/stats';

  static String getV2MeTrainerSelfEmployeeLessonsUrl(String baseUrl) =>
      '${_selfService(baseUrl)}employee/lessons';

  static String getMobileServicesUrl(String baseUrl) =>
      '${_mobile(baseUrl)}services';

  static String getMobileProductsUrl(String baseUrl) =>
      '${_mobile(baseUrl)}products';

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

  static String getTodaySummaryUrl(String baseUrl) =>
      '${_selfService(baseUrl)}today-summary';

  /// Grup dersi takvim olayları (Fitiz schedule / `service-plans/calendar` ile aynı yapı).
  /// Eğitmen: Randevu `v2/me/service-plans/calendar` — `employee_id` JWT’deki kullanıcıdan sunucuda atanır.
  static String getV2ServicePlansCalendarUrl(
    String baseUrl, {
    required String start,
    required String end,
    bool includeDeleted = false,
  }) {
    final b = StringBuffer(
      '${_selfService(baseUrl)}service-plans/calendar?'
      'start=${Uri.encodeQueryComponent(start)}&end=${Uri.encodeQueryComponent(end)}',
    );
    if (includeDeleted) {
      b.write('&include_deleted=1');
    }
    return b.toString();
  }

  static String getV2ServicePlansRootUrl(String baseUrl) =>
      '${_selfService(baseUrl)}service-plans';

  /// Eğitmen self-service — tek plan: GET/PUT/DELETE …/api/v2/me/service-plans/{id}
  static String getV2ServicePlanByIdUrl(String baseUrl, int id) =>
      '${_selfService(baseUrl)}service-plans/$id';

  /// Toplu / tekil yoklama — Fitiz `POST/DELETE …/service-plans/{id}/attendance`.
  static String getV2ServicePlanAttendanceUrl(String baseUrl, int servicePlanId) =>
      '${_selfService(baseUrl)}service-plans/$servicePlanId/attendance';

  /// Hak yakma / iptal — Fitiz `POST/DELETE …/service-plans/{id}/burn`.
  static String getV2ServicePlanBurnUrl(String baseUrl, int servicePlanId) =>
      '${_selfService(baseUrl)}service-plans/$servicePlanId/burn';

  /// Bu derse bağlı paket seçenekleri (api-system özetleri Randevu üzerinden).
  static String getV2TrainerEnrollmentPackageOptionsUrl(
    String baseUrl, {
    required int planId,
    required int enrollmentId,
  }) =>
      '${_selfService(baseUrl)}service-plans/$planId/enrollments/$enrollmentId/package-options';

  /// Enrollment paket güncelleme (`member_register_id`).
  static String getV2TrainerEnrollmentPackageUrl(
    String baseUrl, {
    required int planId,
    required int enrollmentId,
  }) =>
      '${_selfService(baseUrl)}service-plans/$planId/enrollments/$enrollmentId/package';

  /// [applicationType]: örn. `ApplicationType.swimmingCourse.value`
  static String getV2ServicesUrl(String baseUrl, {String? applicationType}) {
    final b = StringBuffer(
      '${_selfService(baseUrl)}services',
    );
    if (applicationType != null && applicationType.isNotEmpty) {
      b.write('?application_type=${Uri.encodeQueryComponent(applicationType)}');
    }
    return b.toString();
  }

  static String getV2GroupLessonLocationsUrl(String baseUrl) =>
      '${_selfService(baseUrl)}group-lesson-locations';

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
