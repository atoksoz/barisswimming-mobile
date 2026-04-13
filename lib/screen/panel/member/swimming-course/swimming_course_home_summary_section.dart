import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/member_home_dashboard_service.dart';
import 'package:e_sport_life/core/utils/attendance_report_status_presentation.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/data/model/attendance_report_detail_item_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Yüzme kursu anasayfa — yalnızca son yoklamalar özeti (metrik / sonraki ders yok).
class SwimmingCourseHomeSummarySection extends StatelessWidget {
  static const double _loadingMinHeight = 100;
  static const double _recentAttendanceRowSpacing = 8;

  const SwimmingCourseHomeSummarySection({
    super.key,
    required this.loading,
    required this.insights,
    this.onRecentAttendanceTap,
  });

  final bool loading;
  final MemberHomeDashboardInsights? insights;
  final VoidCallback? onRecentAttendanceTap;

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

    if (!loading && insights == null) {
      return const SizedBox.shrink();
    }

    final outerWidth = MediaQuery.sizeOf(context).width - 40;

    return Container(
      margin: EdgeInsetsDirectional.fromSTEB(
        20,
        theme.panelHomeBlockGap,
        20,
        0,
      ),
      width: outerWidth,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            spreadRadius: 1,
            color: BlocTheme.theme.panelScaffoldBackgroundColor,
          ),
        ],
        color: theme.defaultWhiteColor,
        border: Border.all(color: theme.defaultGray300Color, width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: loading && insights == null
            ? const SizedBox(
                height: _loadingMinHeight,
                child: Center(child: LoadingIndicatorWidget()),
              )
            : _buildContent(theme, labels, insights!),
      ),
    );
  }

  Widget _buildContent(
    BaseTheme theme,
    AppLabels labels,
    MemberHomeDashboardInsights data,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 10),
          child: Text(
            labels.homeSummarySectionTitle,
            style: theme.panelTitleStyle.copyWith(
              decoration: TextDecoration.underline,
              decorationColor: theme.default900Color,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: _recentAttendanceSection(theme, labels, data.recentAttendance),
        ),
      ],
    );
  }

  Widget _recentAttendanceSection(
    BaseTheme theme,
    AppLabels labels,
    List<AttendanceReportDetailItemModel> items,
  ) {
    final dateFmt = DateFormat('dd.MM.yyyy');
    final c900 = theme.default900Color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onRecentAttendanceTap,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: Container(
          decoration: BoxDecoration(
            color: theme.panelCardBackground,
            border: Border.all(color: theme.defaultGray50Color),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.fact_check_outlined,
                size: 22,
                color: c900,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labels.homeSummaryRecentAttendanceTitle,
                      style: theme.textSmallSemiBold(color: c900),
                    ),
                    const SizedBox(height: 4),
                    if (items.isEmpty)
                      Text(
                        labels.noAttendanceRecords,
                        style: theme.textSmallNormal(
                          color: theme.defaultGray500Color,
                        ),
                      )
                    else
                      for (var i = 0; i < items.length; i++) ...[
                        if (i > 0)
                          const SizedBox(
                            height: _recentAttendanceRowSpacing,
                          ),
                        _recentAttendanceRow(
                          theme,
                          labels,
                          items[i],
                          dateFmt,
                        ),
                      ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAttendancePlanDate(String raw, DateFormat dateFmt) {
    if (raw.isEmpty) return '—';
    try {
      return dateFmt.format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  bool _hasDisplayableTeacherName(String raw) {
    final t = raw.trim();
    return t.isNotEmpty && t != '-';
  }

  Widget _recentAttendanceRow(
    BaseTheme theme,
    AppLabels labels,
    AttendanceReportDetailItemModel item,
    DateFormat dateFmt,
  ) {
    final status =
        AttendanceReportStatusPresentation.resolve(theme, labels, item);
    final dateStr = _formatAttendancePlanDate(item.date, dateFmt);
    final timeStr = (item.time ?? '').trim();
    final when = timeStr.isNotEmpty ? '$dateStr · $timeStr' : dateStr;
    final teacherName = item.employeeName.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.lessonName,
                style: theme.textBodyBold(color: theme.default900Color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (_hasDisplayableTeacherName(teacherName)) ...[
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: theme.defaultGray500Color,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${labels.teacher}: $teacherName',
                        style:
                            theme.textCaption(color: theme.defaultGray700Color),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 4),
              Text(
                when,
                style: theme.textCaption(color: theme.defaultGray500Color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (item.isMakeup) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.event_repeat_outlined,
                      size: 14,
                      color: theme.panelWarningColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      labels.makeupLesson,
                      style: theme.textMini(color: theme.panelWarningColor),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: status.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(status.icon, size: 16, color: status.color),
              const SizedBox(width: 4),
              Text(
                status.label,
                style: theme.textMini(color: status.color),
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
