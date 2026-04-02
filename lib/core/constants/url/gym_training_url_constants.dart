import 'package:e_sport_life/core/extensions/url_slash_extension.dart';

class GymTrainingUrlConstants {
  static String getDietUri = "v1/member/diet";
  static String getMeasurementHistoryUri = "v1/member/measurement-history";
  static String addMeasurementUri = "v1/member/measurement";
  static String getFitnessProgrameUri =
      "v1/member/fitness-programe?fitness_programe_id=";
  static String getPastFitnessProgramesUri = "v1/member/past-fitness-programes";
  static String getFitnessMovementsByDayAndSectionUri =
      "v1/member/fitness-movements-by-day-and-section?";

  static String getDietdDataUrl(String gymTrainingUrl) {
    return gymTrainingUrl.ensureApiPath().ensureTrailingSlash() + getDietUri;
  }

  static String getMeasurementdDataUrl(String gymTrainingUrl) {
    return gymTrainingUrl.ensureApiPath().ensureTrailingSlash() + getMeasurementHistoryUri;
  }

  static String getAddMeasurementUrl(String gymTrainingUrl) {
    return gymTrainingUrl.ensureApiPath().ensureTrailingSlash() + addMeasurementUri;
  }

  static String getDeleteMeasurementUrl(String gymTrainingUrl, int measurementId) {
    return gymTrainingUrl.ensureApiPath().ensureTrailingSlash() + addMeasurementUri + "/$measurementId";
  }

  static String getFitnessProgrameUrl(
      String gymTrainingUrl, int? fitnessProgrameId) {
    return gymTrainingUrl.ensureApiPath().ensureTrailingSlash() +
        getFitnessProgrameUri +
        (fitnessProgrameId == null ? "" : fitnessProgrameId.toString());
  }

  static String getPastFitnessProgramesUrl(String gymTrainingUrl) {
    return gymTrainingUrl.ensureApiPath().ensureTrailingSlash() + getPastFitnessProgramesUri;
  }

  static String getFitnessMovementsByDayAndSectionUrl(
      String gymTrainingUrl, String day, String fitnessProgrameId) {
    return gymTrainingUrl.ensureApiPath().ensureTrailingSlash() +
        getFitnessMovementsByDayAndSectionUri +
        "day=" +
        day +
        "&" +
        "fitness_programe_id=" +
        fitnessProgrameId;
  }

  // ─── V2 (Trainer/Moderator/Admin) ───

  static String _v2(String baseUrl) =>
      baseUrl.ensureApiPath().ensureTrailingSlash() + 'v2/';

  // Fitness Programları
  static String getV2FitnessProgramsUrl(String baseUrl) =>
      '${_v2(baseUrl)}fitness-programs';

  static String getV2FitnessProgramUrl(String baseUrl, int id) =>
      '${_v2(baseUrl)}fitness-programs/$id';

  static String getV2MemberFitnessProgramsUrl(
          String baseUrl, int memberId) =>
      '${_v2(baseUrl)}members/$memberId/fitness-programs';

  static String getV2MemberFitnessProgramDeleteUrl(
          String baseUrl, int memberId, int programId) =>
      '${_v2(baseUrl)}members/$memberId/fitness-programs/$programId';

  // Program Hareketleri
  static String getV2ProgramMovementsUrl(String baseUrl, int programId) =>
      '${_v2(baseUrl)}fitness-programs/$programId/movements';

  static String getV2ProgramMovementUrl(
          String baseUrl, int programId, int movementId) =>
      '${_v2(baseUrl)}fitness-programs/$programId/movements/$movementId';

  // Hareket Kataloğu
  static String getV2FitnessMovementsUrl(String baseUrl) =>
      '${_v2(baseUrl)}fitness-movements';

  // Vücut Ölçümleri
  static String getV2MemberMeasurementsUrl(
          String baseUrl, int memberId) =>
      '${_v2(baseUrl)}members/$memberId/body-measurements';

  static String getV2MemberMeasurementUrl(
          String baseUrl, int memberId, int measurementId) =>
      '${_v2(baseUrl)}members/$memberId/body-measurements/$measurementId';

  static String getV2MemberMeasurementImagesUrl(
          String baseUrl, int memberId, int measurementId) =>
      '${_v2(baseUrl)}members/$memberId/body-measurements/$measurementId/images';

  // Diyetler
  static String getV2DietsUrl(String baseUrl) =>
      '${_v2(baseUrl)}diets';

  static String getV2DietUrl(String baseUrl, int id) =>
      '${_v2(baseUrl)}diets/$id';

  static String getV2MemberDietsUrl(String baseUrl, int memberId) =>
      '${_v2(baseUrl)}members/$memberId/diets';

  static String getV2MemberDietDeleteUrl(
          String baseUrl, int memberId, int dietId) =>
      '${_v2(baseUrl)}members/$memberId/diets/$dietId';
}
