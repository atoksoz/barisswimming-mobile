import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/data/model/attendance_report_detail_item_model.dart';
import 'package:flutter/material.dart';

/// Yoklama satırında geldi / gelmedi / iptal vb. etiket + renk + ikon.
class AttendanceReportStatusPresentation {
  const AttendanceReportStatusPresentation({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  static AttendanceReportStatusPresentation resolve(
    BaseTheme theme,
    AppLabels labels,
    AttendanceReportDetailItemModel item,
  ) {
    if (item.isCancelled) {
      return AttendanceReportStatusPresentation(
        label: labels.cancelledLesson,
        color: theme.panelWarningColor,
        icon: Icons.event_busy_outlined,
      );
    }
    switch (item.attendance) {
      case 1:
        return AttendanceReportStatusPresentation(
          label: labels.attended,
          color: theme.panelPaidColor,
          icon: Icons.check_circle_outline,
        );
      case 2:
        return AttendanceReportStatusPresentation(
          label: labels.burned,
          color: theme.panelDebtColor,
          icon: Icons.local_fire_department_outlined,
        );
      default:
        return AttendanceReportStatusPresentation(
          label: labels.notAttended,
          color: theme.panelWarningColor,
          icon: Icons.cancel_outlined,
        );
    }
  }
}
