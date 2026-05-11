import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/widgets/summary_popup_widget.dart';
import 'package:e_sport_life/data/model/common/trainer_schedule_calendar_event_model.dart';
import 'package:flutter/material.dart';

/// Ders programı kartındaki kontenjan rozeti — öğrenci listesi ([SummaryPopupWidget]).
class TrainerLessonScheduleParticipantsDialog {
  TrainerLessonScheduleParticipantsDialog._();

  static Future<void> show(
    BuildContext context,
    TrainerScheduleCalendarEventModel event,
  ) async {
    final labels = AppLabels.current;

    final List<Map<String, dynamic>> items;
    if (event.reservations.isNotEmpty) {
      items = event.reservations
          .map(
            (r) => <String, dynamic>{
              'member_name': r.memberName,
            },
          )
          .toList();
    } else {
      items = event.enrollments
          .map(
            (e) => <String, dynamic>{
              'member_name': e.memberName,
            },
          )
          .toList();
    }

    if (!context.mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (_) => SummaryPopupWidget(
        title: labels.trainerLessonScheduleStudentListTitle,
        subtitle: event.title.trim().isNotEmpty ? event.title.trim() : null,
        items: items.isEmpty
            ? <Map<String, dynamic>>[
                <String, dynamic>{'_empty': true},
              ]
            : items,
        itemBuilder: (theme, m) {
          if (m['_empty'] == true) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                labels.trainerLessonScheduleStudentListEmpty,
                textAlign: TextAlign.center,
                style: theme.textBody(color: theme.defaultGray600Color),
              ),
            );
          }
          return _participantRow(theme, m);
        },
      ),
    );
  }

  static Widget _participantRow(
    BaseTheme theme,
    Map<String, dynamic> m,
  ) {
    final name = m['member_name']?.toString().trim() ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.person_outline, color: theme.default900Color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name.isNotEmpty ? name : '—',
              style: theme.textBodyBold(color: theme.defaultBlackColor),
            ),
          ),
        ],
      ),
    );
  }
}
