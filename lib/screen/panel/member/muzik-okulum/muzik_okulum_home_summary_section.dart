import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/member_home_dashboard_service.dart';
import 'package:e_sport_life/core/utils/attendance_report_status_presentation.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/data/model/attendance_report_detail_item_model.dart';
import 'package:e_sport_life/data/model/member_home_next_lesson_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Müzik okulu anasayfa — özet metrik kartları (1×3 + bir sonraki ders / dersler).
/// Dış çerçeve ve metrik kutuları [iconButtonWidget] / üst üçlü buton satırı ile aynı ölçü-stil.
///
/// Kapalıyken yalnızca başlık + üç metrik kutusu; bir sonraki ders ve son yoklamalar
/// bölümü `AppLabels.homeSummaryShowMore` / `homeSummaryShowLess` ile açılır.
class MuzikOkulumHomeSummarySection extends StatefulWidget {
  /// [iconButtonWidget] iç hücresi ile aynı.
  static const double _metricCellWidth = 94;
  static const double _metricCellHeight = 102;
  static const double _recentAttendanceRowSpacing = 8;

  const MuzikOkulumHomeSummarySection({
    super.key,
    required this.loading,
    required this.insights,
    this.onActivePackagesTap,
    this.onWeekLessonsTap,
    this.onOverdueTap,
    this.onNextLessonTap,
    this.onRecentAttendanceTap,
  });

  final bool loading;
  final MemberHomeDashboardInsights? insights;

  final VoidCallback? onActivePackagesTap;
  final VoidCallback? onWeekLessonsTap;
  final VoidCallback? onOverdueTap;
  final VoidCallback? onNextLessonTap;
  final VoidCallback? onRecentAttendanceTap;

  @override
  State<MuzikOkulumHomeSummarySection> createState() =>
      _MuzikOkulumHomeSummarySectionState();
}

class _MuzikOkulumHomeSummarySectionState
    extends State<MuzikOkulumHomeSummarySection> {
  /// [true]: bir sonraki ders + son yoklamalar görünür.
  bool _detailExpanded = false;

  @override
  void didUpdateWidget(MuzikOkulumHomeSummarySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.insights != widget.insights) {
      _detailExpanded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

    if (!widget.loading && widget.insights == null) {
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
        child: widget.loading && widget.insights == null
            ? const SizedBox(
                height: MuzikOkulumHomeSummarySection._metricCellHeight,
                child: Center(child: LoadingIndicatorWidget()),
              )
            : _buildContent(theme, labels, widget.insights!),
      ),
    );
  }

  /// Paket donut kartındaki “Detaylı incele” ile aynı tipografi (mavi + alt çizgi).
  Widget _buildExpandToggleText({
    required BaseTheme theme,
    required String text,
    required VoidCallback onTap,
  }) {
    final blue = theme.defaultBlue800Color;
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textCaptionSemiBold(color: blue).copyWith(
                decoration: TextDecoration.underline,
                decorationColor: blue,
              ),
        ),
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
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 10),
                  child: _metricTile(
                    theme: theme,
                    label: labels.homeSummaryActivePackagesLabel,
                    value: '${data.panelSummary.activePackageCount}',
                    caption:
                        '${labels.homeSummaryRemainingRightsLabel}: ${data.totalRemainQuantity}',
                    onTap: widget.onActivePackagesTap,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 10),
                  child: _metricTile(
                    theme: theme,
                    label: labels.homeSummaryThisWeekLessonsLabel,
                    value: '${data.thisWeekLessonCount}',
                    caption: labels.homeSummaryThisWeekLessonsCaption,
                    onTap: widget.onWeekLessonsTap,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                  child: _metricTile(
                    theme: theme,
                    label: labels.homeSummaryOverduePaymentsLabel,
                    value: '${data.overduePaymentCount}',
                    caption: labels.homeSummaryOverduePaymentsCaption,
                    onTap: widget.onOverdueTap,
                    valueColor: data.overduePaymentCount > 0
                        ? theme.panelDangerColor
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!_detailExpanded) ...[
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.bottomEnd,
            child: _buildExpandToggleText(
              theme: theme,
              text: labels.homeSummaryShowMore,
              onTap: () => setState(() => _detailExpanded = true),
            ),
          ),
        ] else ...[
          const SizedBox(height: 10),
          _nextLessonRow(theme, labels, data.nextLesson),
          SizedBox(height: theme.panelHomeBlockGap),
          _recentAttendanceSection(theme, labels, data.recentAttendance),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.bottomEnd,
            child: _buildExpandToggleText(
              theme: theme,
              text: labels.homeSummaryShowLess,
              onTap: () => setState(() => _detailExpanded = false),
            ),
          ),
        ],
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
        onTap: widget.onRecentAttendanceTap,
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
                            height: MuzikOkulumHomeSummarySection
                                ._recentAttendanceRowSpacing,
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

  Widget _nextLessonRow(
    BaseTheme theme,
    AppLabels labels,
    MemberHomeNextLessonModel? next,
  ) {
    final dateTimeFmt = DateFormat('dd.MM.yyyy HH:mm');
    final c900 = theme.default900Color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onNextLessonTap,
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
                Icons.calendar_month_outlined,
                size: 22,
                color: c900,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labels.homeSummaryNextLessonLabel,
                      style: theme.textSmallSemiBold(color: c900),
                    ),
                    const SizedBox(height: 4),
                    if (next == null || next.isEmpty)
                      Text(
                        labels.homeSummaryNextLessonEmpty,
                        style: theme.textSmallNormal(
                          color: theme.defaultGray500Color,
                        ),
                      )
                    else
                      for (var i = 0; i < next.slots.length; i++) ...[
                        _nextLessonTextStack(
                          theme: theme,
                          slot: next.slots[i],
                          dateTimeFormatted: dateTimeFmt.format(
                            next.slots[i].at.toLocal(),
                          ),
                          emphasisColor: c900,
                        ),
                        if (i < next.slots.length - 1)
                          const SizedBox(height: 12),
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

  /// Ders programı kartındaki bilgi sırası (ad → öğretmen → tarih saat), çerçevesiz metin.
  Widget _nextLessonTextStack({
    required BaseTheme theme,
    required MemberHomeNextLessonSlot slot,
    required String dateTimeFormatted,
    required Color emphasisColor,
  }) {
    final teacher = (slot.teacherName ?? '').trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          slot.lessonName,
          style: theme.textBodyBold(color: emphasisColor),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (teacher.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            teacher,
            style: theme.textCaption(color: emphasisColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.access_time_filled,
              size: 14,
              color: emphasisColor,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                dateTimeFormatted,
                style: theme.textCaption(color: emphasisColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _metricTile({
    required BaseTheme theme,
    required String label,
    required String value,
    required String? caption,
    VoidCallback? onTap,
    Color? valueColor,
  }) {
    final vc = valueColor ?? theme.default900Color;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: Container(
          decoration: BoxDecoration(
            color: theme.panelCardBackground,
            border: Border.all(color: theme.defaultGray50Color),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textSmallSemiBold(color: theme.default900Color),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                textAlign: TextAlign.center,
                style: theme.textTitleSemiBold(color: vc),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (caption != null && caption.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  caption,
                  textAlign: TextAlign.center,
                  style: theme.textMini(color: theme.defaultGray500Color),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
