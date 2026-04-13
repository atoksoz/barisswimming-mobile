import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:flutter/material.dart';

/// Ders programı listesi ve anasayfa özet — ortak kart (üst gövde + alt bilgi şeridi).
class PanelMemberLessonCard extends StatelessWidget {
  const PanelMemberLessonCard({
    super.key,
    required this.theme,
    this.topBadgeLabel,
    required this.lessonName,
    this.teacherName,
    this.teacherImageUrl,
    required this.footerPrimaryText,
    this.footerLocation,
    this.showMakeupBadge = false,
    this.makeupLabelText,
    this.personLimit,
    this.margin,
    this.summaryEmphasis = false,
    this.omitTeacherRowWhenEmpty = false,
  });

  final BaseTheme theme;
  final String? topBadgeLabel;
  final String lessonName;
  final String? teacherName;
  final String? teacherImageUrl;
  final String footerPrimaryText;
  final String? footerLocation;
  final bool showMakeupBadge;
  final String? makeupLabelText;
  final int? personLimit;
  final EdgeInsetsGeometry? margin;
  final bool summaryEmphasis;
  /// true: özet — öğretmen yoksa satırı gösterme. false: program — boş metinle satır kalır.
  final bool omitTeacherRowWhenEmpty;

  Color get _nameColor =>
      summaryEmphasis ? theme.default900Color : theme.defaultGray700Color;

  Color get _teacherColor =>
      summaryEmphasis ? theme.default900Color : theme.defaultGray700Color;

  Color get _footerSecondaryColor =>
      summaryEmphasis ? theme.default900Color : theme.defaultGray700Color;

  @override
  Widget build(BuildContext context) {
    final hasTeacher = (teacherName ?? '').trim().isNotEmpty;
    final showTeacherRow =
        hasTeacher || !omitTeacherRowWhenEmpty;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: theme.defaultGray100Color,
        border: Border.all(color: theme.defaultGray200Color),
        borderRadius: BorderRadius.all(Radius.circular(theme.panelCardRadius)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (topBadgeLabel != null && topBadgeLabel!.isNotEmpty) ...[
                  Text(
                    topBadgeLabel!,
                    style: theme.textSmallSemiBold(color: theme.default700Color),
                  ),
                  const SizedBox(height: 4),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        lessonName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style:
                            theme.textBodyBold(color: _nameColor),
                      ),
                    ),
                    if (showMakeupBadge &&
                        makeupLabelText != null &&
                        makeupLabelText!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        makeupLabelText!,
                        style: theme.textMini(color: theme.panelWarningColor),
                      ),
                    ],
                    if (personLimit != null && personLimit! > 0)
                      _CapacityBadge(theme: theme, personLimit: personLimit!),
                  ],
                ),
                if (showTeacherRow) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (teacherImageUrl != null &&
                          teacherImageUrl!.isNotEmpty)
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(teacherImageUrl!),
                        )
                      else
                        CircleAvatar(
                          radius: 16,
                          backgroundColor:
                              theme.default900Color.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.person,
                            color: theme.default900Color,
                            size: 18,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          (teacherName ?? '').trim(),
                          style: theme.textCaption(color: _teacherColor),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.defaultWhiteColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(theme.panelCardRadius),
                bottomRight: Radius.circular(theme.panelCardRadius),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _InfoChip(
                  theme: theme,
                  icon: Icons.access_time_filled,
                  text: footerPrimaryText,
                  color: theme.default900Color,
                ),
                if (footerLocation != null && footerLocation!.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  _InfoChip(
                    theme: theme,
                    icon: Icons.location_on_outlined,
                    text: footerLocation!,
                    color: _footerSecondaryColor,
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

class _CapacityBadge extends StatelessWidget {
  const _CapacityBadge({
    required this.theme,
    required this.personLimit,
  });

  final BaseTheme theme;
  final int personLimit;

  @override
  Widget build(BuildContext context) {
    final Color color = theme.default900Color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '$personLimit',
            style: theme.textMini(color: color),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.theme,
    required this.icon,
    required this.text,
    required this.color,
  });

  final BaseTheme theme;
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: theme.textCaption(color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
