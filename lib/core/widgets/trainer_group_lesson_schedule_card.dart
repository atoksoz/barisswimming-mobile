import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/contants/application_color.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/utils/date_format_utils.dart';
import 'package:e_sport_life/data/model/trainer_schedule_calendar_event_model.dart';
import 'package:flutter/material.dart';

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

/// `SwimmingCourseTrainerLessonScheduleScreen` ile aynı grup ders kartı görünümü.
class TrainerGroupLessonScheduleCard extends StatelessWidget {
  const TrainerGroupLessonScheduleCard({
    super.key,
    required this.data,
    required this.theme,
    required this.labels,
    this.onTap,
    this.bottomActions,
    this.outerMargin = const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 15),
  });

  final TrainerScheduleCalendarEventModel data;
  final BaseTheme theme;
  final AppLabels labels;
  final VoidCallback? onTap;

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
                _CapacityBadge(data: data, theme: theme),
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
            child: _InfoRows(data: data, theme: theme, labels: labels),
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
    this.outerMargin = EdgeInsets.zero,
  });

  final TrainerScheduleCalendarEventModel data;
  final BaseTheme theme;
  final AppLabels labels;
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
            _CapacityBadge(data: data, theme: theme),
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
  });

  final TrainerScheduleCalendarEventModel data;
  final BaseTheme theme;

  @override
  Widget build(BuildContext context) {
    final limit = data.personLimit ?? 0;
    final isFull = limit > 0 && data.reservationCount >= limit;
    final contentColor =
        isFull ? theme.defaultRed700Color : theme.default900Color;

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
            '${data.reservationCount}/$limit',
            style: theme.textSmall(color: contentColor),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
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

class _InfoRows extends StatelessWidget {
  const _InfoRows({
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
      _InfoItem(
        theme: theme,
        icon: Icons.access_time_filled,
        label: labels.groupLessonScheduleLessonTimeLabel,
        value: timeRange.isNotEmpty ? timeRange : data.start,
      ),
    ];

    if (data.personLimit != null && data.personLimit! > 0) {
      infoItems.add(
        _InfoItem(
          theme: theme,
          icon: Icons.event_available,
          label: labels.groupLessonScheduleCapacityLabel,
          value: '${data.personLimit} ${labels.person}',
        ),
      );
    }

    if (data.minLimit > 0) {
      infoItems.add(
        _InfoItem(
          theme: theme,
          icon: Icons.group_outlined,
          label: labels.minParticipation,
          value: '${data.minLimit} ${labels.person}',
        ),
      );
    }

    if (data.locationName != null && data.locationName!.trim().isNotEmpty) {
      infoItems.add(
        _InfoItem(
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
