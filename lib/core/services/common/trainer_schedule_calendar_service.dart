import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/data/model/common/trainer_schedule_calendar_event_model.dart';

/// Randevu grup ders takvimi — ortak parse/fetch (Fitiz schedule veri modeli).
class TrainerScheduleCalendarService {
  TrainerScheduleCalendarService._();

  static List<TrainerScheduleCalendarEventModel> parseEventList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map((e) => Map<String, dynamic>.from(e as Map))
        .map(TrainerScheduleCalendarEventModel.fromJson)
        .toList();
  }

  static Future<List<TrainerScheduleCalendarEventModel>> fetchCalendar({
    required String url,
    required String token,
  }) async {
    final result = await RequestUtil.getJson(url, token: token);
    if (!result.isSuccess || result.output == null) {
      return const [];
    }
    return parseEventList(result.output);
  }
}
