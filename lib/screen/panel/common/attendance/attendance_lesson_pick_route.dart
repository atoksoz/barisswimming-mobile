import 'package:e_sport_life/data/model/common/trainer_schedule_calendar_event_model.dart';
import 'package:e_sport_life/screen/panel/trainer/common/lesson_schedule/trainer_lesson_schedule_screen.dart';
import 'package:flutter/material.dart';

/// Yoklamada henüz ders seçili değilse kullanılacak takvim seçim rotası (`attendance_screen` ↔ program ekranı döngüsünü önlemek için ayrı dosya).
Future<TrainerScheduleCalendarEventModel?> pushLessonPickForAttendance(
  BuildContext context,
) {
  return Navigator.of(context).push<TrainerScheduleCalendarEventModel>(
    MaterialPageRoute(
      builder: (_) => const TrainerLessonScheduleScreen(
        pickLessonForAttendance: true,
      ),
    ),
  );
}
