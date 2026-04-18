import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/core/constants/trainer_today_dashboard_row_kind.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/utils/date_format_utils.dart';
import 'package:e_sport_life/core/widgets/summary_popup_widget.dart';
import 'package:e_sport_life/data/model/trainer/trainer_today_dashboard_model.dart';
import 'package:flutter/material.dart';

/// Yüzme kursu eğitmen anasayfa — bugünkü yoklama ve bugünün özeti diyalogları.
class SwimmingCourseTrainerTodayDashboardDialogs {
  SwimmingCourseTrainerTodayDashboardDialogs._();

  static String _singleLineTitle(String raw) =>
      raw.replaceAll('\n', ' ').trim();

  static Future<void> showTodayAttendance(
    BuildContext context,
    TrainerTodayDashboardModel model,
  ) async {
    final labels = AppLabels.current;
    final items = model.todayAttendances
        .map(
          (a) => <String, dynamic>{
            'member_name': a.memberName,
            'plan_time': a.planTime ?? '',
            'note': a.note ?? '',
          },
        )
        .toList();

    await showDialog<void>(
      context: context,
      builder: (_) => SummaryPopupWidget(
        title: _singleLineTitle(labels.trainerHomeTodayAttendanceTitle),
        subtitle: model.date.isNotEmpty
            ? DateFormatUtils.formatDate(model.date)
            : null,
        items: items,
        itemBuilder: (theme, m) => _attendanceItem(theme, labels, m),
      ),
    );
  }

  static Widget _attendanceItem(
    BaseTheme theme,
    AppLabels labels,
    Map<String, dynamic> m,
  ) {
    final name = m['member_name']?.toString() ?? '';
    final time = m['plan_time']?.toString() ?? '';
    final note = m['note']?.toString() ?? '';
    final line2 = time.isNotEmpty ? '${labels.time}: $time' : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.fact_check_outlined, color: theme.default900Color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (name.isNotEmpty)
                  Text(
                    name,
                    style: theme.textBodyBold(color: theme.defaultBlackColor),
                  ),
                if (line2.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    line2,
                    style: theme.textSmallNormal(color: theme.defaultGray600Color),
                  ),
                ],
                if (note.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    note,
                    style: theme.textCaption(color: theme.defaultGray500Color),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static List<Map<String, dynamic>> _summaryItems(
    AppLabels labels,
    TrainerTodayDashboardModel model,
  ) {
    final out = <Map<String, dynamic>>[];
    for (final g in model.groupLessons) {
      final timeRange = _timeRange(g.startTime, g.endTime);
      final cap = g.capacity;
      final en = g.enrollmentCount;
      String? capLine;
      if (cap != null && en != null) {
        capLine = '${labels.groupLessonScheduleCapacityLabel}: $en / $cap';
      }
      final loc = g.locationName?.trim();
      out.add({
        'kind': TrainerTodayDashboardRowKind.groupLesson,
        'section': labels.todayGroupLessons,
        'title': g.name,
        'line2': timeRange,
        'line3': [if (capLine != null) capLine, if (loc != null && loc.isNotEmpty) loc]
            .join(' · '),
      });
    }
    for (final p in model.ptPlans) {
      final times = p.times.isNotEmpty ? p.times.join(', ') : '';
      out.add({
        'kind': TrainerTodayDashboardRowKind.ptPlan,
        'section': labels.todayPtReservations,
        'title': p.name,
        'line2': times,
        'line3': '',
      });
    }
    for (final q in model.quickReservations) {
      final time = q.planTime?.trim() ?? '';
      out.add({
        'kind': TrainerTodayDashboardRowKind.quickReservation,
        'section': labels.trainerTodayDashboardQuickReservationSectionTitle,
        'title': q.memberName,
        'line2': time.isNotEmpty ? '${labels.time}: $time' : '',
        'line3': '',
      });
    }
    return out;
  }

  static String _timeRange(String? start, String? end) {
    final s = start?.trim() ?? '';
    final e = end?.trim() ?? '';
    if (s.isEmpty && e.isEmpty) return '';
    if (s.isNotEmpty && e.isNotEmpty) return '$s – $e';
    return s.isNotEmpty ? s : e;
  }

  static IconData _iconForKind(String? kind) {
    switch (kind) {
      case TrainerTodayDashboardRowKind.groupLesson:
        return Icons.calendar_month_outlined;
      case TrainerTodayDashboardRowKind.ptPlan:
        return Icons.fitness_center_outlined;
      case TrainerTodayDashboardRowKind.quickReservation:
        return Icons.event_available_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  static Future<void> showTodaySummary(
    BuildContext context,
    TrainerTodayDashboardModel model,
  ) async {
    final labels = AppLabels.current;
    final items = _summaryItems(labels, model);

    await showDialog<void>(
      context: context,
      builder: (_) => SummaryPopupWidget(
        title: _singleLineTitle(labels.todaySummaryTitle),
        subtitle: model.date.isNotEmpty
            ? DateFormatUtils.formatDate(model.date)
            : null,
        items: items,
        itemBuilder: (theme, m) => _summaryItem(theme, m),
      ),
    );
  }

  static Widget _summaryItem(BaseTheme theme, Map<String, dynamic> m) {
    final section = m['section']?.toString() ?? '';
    final title = m['title']?.toString() ?? '';
    final line2 = m['line2']?.toString() ?? '';
    final line3 = m['line3']?.toString() ?? '';
    final kind = m['kind']?.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_iconForKind(kind), color: theme.default900Color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (section.isNotEmpty) ...[
                  Text(
                    section,
                    style: theme.textSmallSemiBold(color: theme.default700Color),
                  ),
                  const SizedBox(height: 4),
                ],
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: theme.textBodyBold(color: theme.defaultBlackColor),
                  ),
                if (line2.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    line2,
                    style: theme.textSmallNormal(color: theme.defaultGray600Color),
                  ),
                ],
                if (line3.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    line3,
                    style: theme.textCaption(color: theme.defaultGray500Color),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
