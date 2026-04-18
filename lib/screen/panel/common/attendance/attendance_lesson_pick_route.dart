import 'package:e_sport_life/data/model/trainer_schedule_calendar_event_model.dart';
import 'package:e_sport_life/screen/panel/trainer/swimming-course/lesson_schedule/swimming_course_trainer_lesson_schedule_screen.dart';
import 'package:flutter/material.dart';

/// Yoklamada henüz ders seçili değilse kullanılacak takvim seçim rotası (`attendance_screen` ↔ program ekranı döngüsünü önlemek için ayrı dosya).
Future<TrainerScheduleCalendarEventModel?> pushLessonPickForAttendance(
  BuildContext context,
) {
  return Navigator.of(context).push<TrainerScheduleCalendarEventModel>(
    MaterialPageRoute(
      builder: (_) => const SwimmingCourseTrainerLessonScheduleScreen(
        pickLessonForAttendance: true,
      ),
    ),
  );
}
