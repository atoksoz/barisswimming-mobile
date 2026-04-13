import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/member_today_summary_service.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/core/widgets/summary_popup_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Trainer panelindeki [SummaryPopupWidget] ile bugünkü işlem listesi.
class MemberTodaySummaryPopup {
  MemberTodaySummaryPopup._();

  /// Alt özet metni kaldırıldı; boş döner. Eski hot-reload isolate uyumu için tutulur.
  // ignore: unused_element
  static String _buildSubtitle(List<Map<String, dynamic>> items, AppLabels l) {
    return '';
  }

  static IconData _iconForKind(String? kind) {
    switch (kind) {
      case MemberTodaySummaryService.kindLesson:
        return Icons.calendar_month_outlined;
      case MemberTodaySummaryService.kindPlannedPayment:
        return Icons.payments_outlined;
      case MemberTodaySummaryService.kindPackageSale:
        return Icons.shopping_bag_outlined;
      case MemberTodaySummaryService.kindCollection:
        return Icons.account_balance_wallet_outlined;
      case MemberTodaySummaryService.kindAttendance:
        return Icons.fact_check_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  static Widget _buildItem(
    BaseTheme theme,
    Map<String, dynamic> item,
    AppLabels labels,
  ) {
    final kind = item['kind']?.toString();
    var title = item['title']?.toString().trim() ?? '';
    if (title == '—' || title == '-' || title == '–') {
      title = '';
    }
    final line2 = item['line2']?.toString() ?? '';
    final line3Raw = item['line3']?.toString();

    String? line3 = line3Raw;
    if (kind == MemberTodaySummaryService.kindPlannedPayment) {
      final paid = item['_paid'] == true;
      line3 = paid ? labels.paidStatus : labels.unpaidStatus;
    } else if (kind == MemberTodaySummaryService.kindAttendance) {
      final ai = item['_attendance'];
      final v = ai is int ? ai : int.tryParse(ai?.toString() ?? '') ?? 0;
      if (v == 1) {
        line3 = labels.attended;
      } else if (v == 2) {
        line3 = labels.burned;
      } else {
        line3 = labels.notAttended;
      }
      if (item['_is_makeup'] == true) {
        line3 = '${labels.makeupLesson} · $line3';
      }
    } else if (kind == MemberTodaySummaryService.kindLesson) {
      final isMakeup = item['_is_makeup'] == true;
      final loc = line3Raw?.trim();
      if (isMakeup) {
        if (loc != null && loc.isNotEmpty) {
          line3 = '${labels.makeupLesson} · $loc';
        } else {
          line3 = labels.makeupLesson;
        }
      }
    }

    final String? kindBadge = switch (kind) {
      MemberTodaySummaryService.kindPlannedPayment =>
        labels.summaryRowBadgePlannedPayment,
      MemberTodaySummaryService.kindPackageSale =>
        labels.summaryRowBadgeStatementSale,
      MemberTodaySummaryService.kindCollection =>
        labels.summaryRowBadgeStatementCollection,
      MemberTodaySummaryService.kindLesson =>
        labels.summaryRowBadgeMyLessons,
      _ => null,
    };

    final bool line3EmphasizeMakeup = (kind ==
                MemberTodaySummaryService.kindLesson ||
            kind == MemberTodaySummaryService.kindAttendance) &&
        item['_is_makeup'] == true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _iconForKind(kind),
            color: theme.default900Color,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (kindBadge != null) ...[
                  Text(
                    kindBadge,
                    style: theme.textSmallSemiBold(
                      color: theme.default700Color,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                if (title.isNotEmpty) ...[
                  Text(
                    title,
                    style: theme.textBodyBold(color: theme.defaultBlackColor),
                  ),
                  if (line2.isNotEmpty) const SizedBox(height: 4),
                ],
                if (line2.isNotEmpty)
                  Text(
                    line2,
                    style: theme.textSmallNormal(
                      color: theme.defaultGray600Color,
                    ),
                  ),
                if (line3 != null && line3.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    line3,
                    style: line3EmphasizeMakeup
                        ? theme.textCaption(color: theme.panelWarningColor)
                        : theme.textCaption(color: theme.defaultGray500Color),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> show(BuildContext context) async {
    final labels = AppLabels.current;
    final config = context.read<ExternalApplicationsConfigCubit>().state;
    if (config == null || config.apiHamamspaUrl.isEmpty) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: BlocTheme.theme.defaultWhiteColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const LoadingIndicatorWidget(),
          ),
        ),
      ),
    );

    try {
      final items = await MemberTodaySummaryService.loadTodayOperationItems(
        apiUrl: config.apiHamamspaUrl,
        randevuUrl: config.onlineReservation,
      );

      if (!context.mounted) return;
      Navigator.of(context).pop();

      if (!context.mounted) return;
      showDialog<void>(
        context: context,
        builder: (ctx) => _MemberTodaySummaryDialogBody(
          items: items,
          labels: labels,
        ),
      );
    } catch (_) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  /// Özet kartı — bu haftaki ders sayısı kutusu ([MemberHomeDashboardService] ile aynı hafta kuralı).
  static Future<void> showThisWeekLessons(BuildContext context) async {
    final labels = AppLabels.current;
    final config = context.read<ExternalApplicationsConfigCubit>().state;
    if (config == null || config.onlineReservation.isEmpty) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: BlocTheme.theme.defaultWhiteColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const LoadingIndicatorWidget(),
          ),
        ),
      ),
    );

    try {
      final items = await MemberTodaySummaryService.loadThisWeekScheduleLessons(
        randevuUrl: config.onlineReservation,
        labels: labels,
      );

      if (!context.mounted) return;
      Navigator.of(context).pop();

      if (!context.mounted) return;
      showDialog<void>(
        context: context,
        builder: (ctx) => _MemberThisWeekLessonsDialogBody(
          items: items,
          labels: labels,
        ),
      );
    } catch (_) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}

/// Bu hafta ders listesi — [SummaryPopupWidget] + [MemberTodaySummaryPopup._buildItem].
class _MemberThisWeekLessonsDialogBody extends StatelessWidget {
  const _MemberThisWeekLessonsDialogBody({
    required this.items,
    required this.labels,
  });

  final List<Map<String, dynamic>> items;
  final AppLabels labels;

  @override
  Widget build(BuildContext context) {
    final cap = labels.homeSummaryThisWeekLessonsCaption.trim();
    return SummaryPopupWidget(
      title: labels.homeSummaryThisWeekLessonsLabel.replaceAll('\n', ' ').trim(),
      subtitle: cap.isEmpty ? null : cap,
      items: items,
      itemBuilder: (t, item) =>
          MemberTodaySummaryPopup._buildItem(t, item, labels),
    );
  }
}

/// Ayrı widget: `showDialog` builder closure'ında static metot referansı birikmesini azaltır.
class _MemberTodaySummaryDialogBody extends StatelessWidget {
  const _MemberTodaySummaryDialogBody({
    required this.items,
    required this.labels,
  });

  final List<Map<String, dynamic>> items;
  final AppLabels labels;

  @override
  Widget build(BuildContext context) {
    return SummaryPopupWidget(
      title: labels.todaySummaryTitle.replaceAll('\n', ' '),
      items: items,
      itemBuilder: (t, item) =>
          MemberTodaySummaryPopup._buildItem(t, item, labels),
      omitDividerBetween: (prev, next) {
        const stmtKinds = {
          MemberTodaySummaryService.kindPackageSale,
          MemberTodaySummaryService.kindCollection,
        };
        final pk = prev['kind']?.toString();
        final nk = next['kind']?.toString();
        return stmtKinds.contains(pk) && stmtKinds.contains(nk);
      },
    );
  }
}
