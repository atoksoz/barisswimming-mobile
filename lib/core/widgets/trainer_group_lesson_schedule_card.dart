import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/contants/application_color.dart';
import 'package:e_sport_life/core/constants/reservation_attendance.dart';
import 'package:e_sport_life/core/enums/supported_locale.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/utils/date_format_utils.dart';
import 'package:e_sport_life/data/model/common/trainer_schedule_calendar_event_model.dart';
import 'package:e_sport_life/data/model/muzik_okulum/trainer/trainer_employee_muzik_card_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Ders programı ve yoklama ders seçimi ile paylaşılan kart stilleri (edit/sil pill’leri dahil).
class TrainerGroupLessonScheduleCardStyle {
  TrainerGroupLessonScheduleCardStyle._();

  static const EdgeInsets headerPillPadding =
      EdgeInsets.symmetric(horizontal: 10, vertical: 4);
  static const double headerPillRadius = 20;

  static BoxDecoration headerPillDecoration(Color contentColor) {
    return BoxDecoration(
      color: contentColor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(headerPillRadius),
    );
  }
}

/// `TrainerLessonScheduleScreen` ile aynı grup ders kartı görünümü.
class TrainerGroupLessonScheduleCard extends StatelessWidget {
  const TrainerGroupLessonScheduleCard({
    super.key,
    required this.data,
    required this.theme,
    required this.labels,
    this.onTap,
    /// Kontenjan rozeti (sağ üst); örn. müzik okulu — öğrenci listesi popup’ı.
    this.onCapacityBadgeTap,
    this.bottomActions,
    this.outerMargin = const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 15),
  });

  final TrainerScheduleCalendarEventModel data;
  final BaseTheme theme;
  final AppLabels labels;
  final VoidCallback? onTap;
  final VoidCallback? onCapacityBadgeTap;

  /// Örn. düzenle/sil pill satırı; null ise gösterilmez (yoklama seçiminde).
  final Widget? bottomActions;

  /// Ders programı: ekran kenarından 20; yoklama kartı içinde gömülü kullanımda [EdgeInsets.zero] vb.
  final EdgeInsetsGeometry outerMargin;

  @override
  Widget build(BuildContext context) {
    final inner = Container(
      decoration: BoxDecoration(
        color: ApplicationColor.primaryBoxBackground,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: theme.default900Color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: outerMargin,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  data.title,
                  style: theme.textLabelBold(color: theme.default900Color),
                  maxLines: 4,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (data.personLimit != null && data.personLimit! > 0) ...[
                const SizedBox(width: 8),
                _CapacityBadge(
                  data: data,
                  theme: theme,
                  onTap: onCapacityBadgeTap,
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.default900Color.withValues(alpha: 0.1),
                child: Icon(
                  Icons.person,
                  color: theme.default900Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.employeeName,
                      style:
                          theme.textBodyBold(color: theme.default900Color),
                    ),
                    Text(
                      labels.trainer,
                      style: theme.textMini(
                        color:
                            theme.default900Color.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.default900Color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _CalendarEventInfoRows(data: data, theme: theme, labels: labels),
          ),
          if (bottomActions != null) ...[
            const SizedBox(height: 16),
            bottomActions!,
          ],
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        child: inner,
      );
    }
    return inner;
  }
}

/// Yalnız üst satır (ders başlığı + doluluk) — yoklama özet görünümü için tam kart görünümü ile aynı çerçeve.
class TrainerGroupLessonSchedulePeekCard extends StatelessWidget {
  const TrainerGroupLessonSchedulePeekCard({
    super.key,
    required this.data,
    required this.theme,
    required this.labels,
    this.onCapacityBadgeTap,
    this.outerMargin = EdgeInsets.zero,
  });

  final TrainerScheduleCalendarEventModel data;
  final BaseTheme theme;
  final AppLabels labels;
  final VoidCallback? onCapacityBadgeTap;
  final EdgeInsetsGeometry outerMargin;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ApplicationColor.primaryBoxBackground,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: theme.default900Color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: outerMargin,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              data.title,
              style: theme.textLabelBold(color: theme.default900Color),
              maxLines: 4,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (data.personLimit != null && data.personLimit! > 0) ...[
            const SizedBox(width: 8),
            _CapacityBadge(
              data: data,
              theme: theme,
              onTap: onCapacityBadgeTap,
            ),
          ],
        ],
      ),
    );
  }
}

class _CapacityBadge extends StatelessWidget {
  const _CapacityBadge({
    required this.data,
    required this.theme,
    this.onTap,
  });

  final TrainerScheduleCalendarEventModel data;
  final BaseTheme theme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final limit = data.personLimit ?? 0;
    final isFull = limit > 0 && data.reservationCount >= limit;
    final contentColor =
        isFull ? theme.defaultRed700Color : theme.default900Color;

    final pill = Container(
      padding: TrainerGroupLessonScheduleCardStyle.headerPillPadding,
      decoration:
          TrainerGroupLessonScheduleCardStyle.headerPillDecoration(contentColor),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people, size: 14, color: contentColor),
          const SizedBox(width: 4),
          Text(
            '${data.reservationCount}/$limit',
            style: theme.textSmall(color: contentColor),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return pill;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(TrainerGroupLessonScheduleCardStyle.headerPillRadius),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: pill,
        ),
      ),
    );
  }
}

/// Ders programı kartındaki gri kutu içi bilgi satırı (ikon + etiket + değer).
class TrainerScheduleCardInfoRow extends StatelessWidget {
  const TrainerScheduleCardInfoRow({
    super.key,
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
  });

  final BaseTheme theme;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.defaultWhiteColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: theme.default800Color,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textMini(
                  color: theme.default900Color.withValues(alpha: 0.5),
                ),
              ),
              Text(
                value,
                style: theme.textSmall(color: theme.default900Color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CalendarEventInfoRows extends StatelessWidget {
  const _CalendarEventInfoRows({
    required this.data,
    required this.theme,
    required this.labels,
  });

  final TrainerScheduleCalendarEventModel data;
  final BaseTheme theme;
  final AppLabels labels;

  @override
  Widget build(BuildContext context) {
    final timeRange = DateFormatUtils.formatLocalHmRange(
      data.start,
      data.end,
      durationHours: data.durationHours,
    );
    final infoItems = <Widget>[
      TrainerScheduleCardInfoRow(
        theme: theme,
        icon: Icons.access_time_filled,
        label: labels.groupLessonScheduleLessonTimeLabel,
        value: timeRange.isNotEmpty ? timeRange : data.start,
      ),
    ];

    if (data.personLimit != null && data.personLimit! > 0) {
      infoItems.add(
        TrainerScheduleCardInfoRow(
          theme: theme,
          icon: Icons.event_available,
          label: labels.groupLessonScheduleCapacityLabel,
          value: '${data.personLimit} ${labels.person}',
        ),
      );
    }

    if (data.minLimit > 0) {
      infoItems.add(
        TrainerScheduleCardInfoRow(
          theme: theme,
          icon: Icons.group_outlined,
          label: labels.minParticipation,
          value: '${data.minLimit} ${labels.person}',
        ),
      );
    }

    if (data.locationName != null && data.locationName!.trim().isNotEmpty) {
      infoItems.add(
        TrainerScheduleCardInfoRow(
          theme: theme,
          icon: Icons.location_on,
          label: labels.location,
          value: data.locationName!.trim(),
        ),
      );
    }

    final rows = <Widget>[];
    for (var i = 0; i < infoItems.length; i += 2) {
      rows.add(
        Row(
          children: [
            Expanded(child: infoItems[i]),
            if (i + 1 < infoItems.length)
              Expanded(child: infoItems[i + 1])
            else
              const Expanded(child: SizedBox()),
          ],
        ),
      );
      if (i + 2 < infoItems.length) {
        rows.add(const SizedBox(height: 10));
      }
    }

    return Column(children: rows);
  }
}

/// Verdiğim dersler — [TrainerGroupLessonScheduleCard] ile aynı çerçeve ve gri bilgi kutusu;
/// öğretmen satırı yok; yoklama gri kutunun içinde satır satır gösterilir.
class TrainerDeliveredLessonSessionCard extends StatelessWidget {
  const TrainerDeliveredLessonSessionCard({
    super.key,
    required this.theme,
    required this.labels,
    required this.session,
    this.outerMargin = const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 15),
  });

  /// Takvim kartı `_CalendarEventInfoRows` ile aynı satır aralığı.
  static const double _stackedInfoGap = 10;

  final BaseTheme theme;
  final AppLabels labels;
  final TrainerEmployeeLessonSessionModel session;
  final EdgeInsetsGeometry outerMargin;

  static String _weekdayAndDateDots(String dateYmd) {
    if (dateYmd.isEmpty) return '';
    try {
      final d = DateTime.parse(dateYmd);
      final loc =
          AppLabels.currentLocale == SupportedLocale.tr ? 'tr_TR' : 'en_US';
      final dayName = DateFormat.EEEE(loc).format(d);
      final dateDots = DateFormatUtils.formatDayMonthYearDots(dateYmd);
      return '$dayName, $dateDots';
    } catch (_) {
      return dateYmd;
    }
  }

  /// Geldi: success, gelmedi: warning, yandı: danger.
  static Color _attendanceBadgeColor(BaseTheme theme, int attendance) {
    if (attendance == ReservationAttendanceValue.attended) {
      return theme.panelSuccessColor;
    }
    if (attendance == ReservationAttendanceValue.burned) {
      return theme.panelDangerColor;
    }
    return theme.panelWarningColor;
  }

  static String _attendanceLabel(AppLabels labels, int attendance) {
    if (attendance == ReservationAttendanceValue.attended) {
      return labels.attended;
    }
    if (attendance == ReservationAttendanceValue.burned) {
      return labels.burned;
    }
    return labels.notAttended;
  }

  @override
  Widget build(BuildContext context) {
    final dateValue = _weekdayAndDateDots(session.dateYmd);
    final timeValue = session.timeHm.trim();
    final count = session.participants.length;

    final dateTimeInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TrainerScheduleCardInfoRow(
          theme: theme,
          icon: Icons.calendar_today_outlined,
          label: labels.date,
          value: dateValue.isNotEmpty ? dateValue : '—',
        ),
        SizedBox(height: _stackedInfoGap),
        TrainerScheduleCardInfoRow(
          theme: theme,
          icon: Icons.access_time_filled,
          label: labels.groupLessonScheduleLessonTimeLabel,
          value: timeValue.isNotEmpty ? timeValue : '—',
        ),
        SizedBox(height: _stackedInfoGap),
        _DeliveredLessonAttendanceRoll(
          theme: theme,
          labels: labels,
          participants: session.participants,
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: ApplicationColor.primaryBoxBackground,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: theme.default900Color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: outerMargin,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  session.lessonName,
                  style: theme.textLabelBold(color: theme.default900Color),
                  maxLines: 4,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (session.isMakeup) ...[
                const SizedBox(width: 8),
                Container(
                  padding: TrainerGroupLessonScheduleCardStyle.headerPillPadding,
                  decoration:
                      TrainerGroupLessonScheduleCardStyle.headerPillDecoration(
                    theme.panelWarningColor,
                  ),
                  child: Text(
                    labels.makeupLesson,
                    style: theme.textMini(color: theme.panelWarningColor),
                  ),
                ),
              ],
              if (count > 0) ...[
                const SizedBox(width: 8),
                _DeliveredLessonParticipantCountBadge(
                  theme: theme,
                  count: count,
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.default900Color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: dateTimeInfo,
          ),
        ],
      ),
    );
  }
}

/// Gri kutuda yoklama — [TrainerScheduleCardInfoRow] ile hizalı ikon sütunu.
class _DeliveredLessonAttendanceRoll extends StatelessWidget {
  const _DeliveredLessonAttendanceRoll({
    required this.theme,
    required this.labels,
    required this.participants,
  });

  final BaseTheme theme;
  final AppLabels labels;
  final List<TrainerEmployeeLessonParticipantModel> participants;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.defaultWhiteColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.fact_check_outlined,
            size: 16,
            color: theme.default800Color,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                labels.trainerMyLessonsAttendanceRollHeading,
                style: theme.textMini(
                  color: theme.default900Color.withValues(alpha: 0.5),
                ),
              ),
              SizedBox(height: theme.panelTightVerticalGap * 2),
              if (participants.isEmpty)
                Text(
                  '—',
                  style: theme.textSmall(color: theme.default900Color),
                )
              else
                for (var i = 0; i < participants.length; i++) ...[
                  if (i > 0) SizedBox(height: theme.panelCompactInset),
                  _DeliveredLessonAttendanceRollRow(
                    theme: theme,
                    labels: labels,
                    participant: participants[i],
                  ),
                ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DeliveredLessonAttendanceRollRow extends StatelessWidget {
  const _DeliveredLessonAttendanceRollRow({
    required this.theme,
    required this.labels,
    required this.participant,
  });

  final BaseTheme theme;
  final AppLabels labels;
  final TrainerEmployeeLessonParticipantModel participant;

  @override
  Widget build(BuildContext context) {
    final accent = TrainerDeliveredLessonSessionCard._attendanceBadgeColor(
      theme,
      participant.attendance,
    );
    final statusText =
        TrainerDeliveredLessonSessionCard._attendanceLabel(labels, participant.attendance);
    final name = participant.studentName.trim().isNotEmpty
        ? participant.studentName.trim()
        : '—';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            name,
            style: theme.textSmall(color: theme.default900Color),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: TrainerGroupLessonScheduleCardStyle.headerPillPadding,
          decoration:
              TrainerGroupLessonScheduleCardStyle.headerPillDecoration(accent),
          child: Text(
            statusText,
            style: theme.textMini(color: accent),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _DeliveredLessonParticipantCountBadge extends StatelessWidget {
  const _DeliveredLessonParticipantCountBadge({
    required this.theme,
    required this.count,
  });

  final BaseTheme theme;
  final int count;

  @override
  Widget build(BuildContext context) {
    final contentColor = theme.default900Color;
    return Container(
      padding: TrainerGroupLessonScheduleCardStyle.headerPillPadding,
      decoration:
          TrainerGroupLessonScheduleCardStyle.headerPillDecoration(contentColor),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people, size: 14, color: contentColor),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: theme.textSmall(color: contentColor),
          ),
        ],
      ),
    );
  }
}

