import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/utils/payment_reminder_due_label_util.dart';
import 'package:e_sport_life/data/model/member_home_reminder_payment_model.dart';
import 'package:flutter/material.dart';

/// [payment_plan_list_screen] ile aynı tutarlılık.

/// Anasayfa — yaklaşan planlı ödemeler (duyurular bu bölümde yok; header’da ikon).
class SwimmingCourseHomeRemindersSection extends StatelessWidget {
  const SwimmingCourseHomeRemindersSection({
    super.key,
    required this.paymentReminders,
    this.onOpenPaymentPlans,
    this.maxVisibleItems = 5,
  });

  final List<MemberHomeReminderPaymentModel> paymentReminders;
  final VoidCallback? onOpenPaymentPlans;
  final int maxVisibleItems;

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;
    final outerWidth = MediaQuery.sizeOf(context).width - 40;
    final visiblePayments = paymentReminders.take(maxVisibleItems).toList();

    if (visiblePayments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsetsDirectional.fromSTEB(
        20,
        theme.panelHomeBlockGap,
        20,
        0,
      ),
      width: outerWidth,
      decoration: _outerDecoration(theme),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 4, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      labels.homeRemindersSectionTitle,
                      style: theme.panelTitleStyle.copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: theme.default900Color,
                      ),
                    ),
                  ),
                  if (onOpenPaymentPlans != null &&
                      paymentReminders.length > maxVisibleItems)
                    TextButton(
                      onPressed: onOpenPaymentPlans,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: theme.default900Color,
                        textStyle: theme.panelButtonTextStyle,
                      ),
                      child: Text(labels.homeRemindersSeeAll),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 6),
              child: Text(
                labels.homeRemindersUpcomingPaymentsSubtitle,
                style: theme.textLabel(color: theme.default900Color),
              ),
            ),
            for (var i = 0; i < visiblePayments.length; i++) ...[
              _ReminderPaymentRow(
                theme: theme,
                labels: labels,
                model: visiblePayments[i],
                onTap: onOpenPaymentPlans,
              ),
              if (i < visiblePayments.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.default900Color,
                ),
            ],
          ],
        ),
      ),
    );
  }

  static BoxDecoration _outerDecoration(BaseTheme theme) {
    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          spreadRadius: 1,
          color: BlocTheme.theme.panelScaffoldBackgroundColor,
        ),
      ],
      color: theme.defaultWhiteColor,
      border: Border.all(color: theme.defaultGray300Color, width: 1),
      borderRadius: const BorderRadius.all(Radius.circular(20)),
    );
  }
}

class _ReminderPaymentRow extends StatelessWidget {
  const _ReminderPaymentRow({
    required this.theme,
    required this.labels,
    required this.model,
    this.onTap,
  });

  final BaseTheme theme;
  final AppLabels labels;
  final MemberHomeReminderPaymentModel model;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatPaymentDate(model.paymentDateLocal);
    final relative = PaymentReminderDueLabelUtil.relativeDueText(
      labels,
      model.paymentDateLocal,
    );
    final expl = model.explanation.trim();
    final statusColor = theme.panelWarningColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${model.amount.toStringAsFixed(2)}${AppLabels.current.currencySuffix}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textBodyBold(color: theme.default900Color),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$dateStr - $relative',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textCaption(color: theme.defaultGray600Color),
                    ),
                    if (expl.isNotEmpty &&
                        expl != '-' &&
                        expl != '—' &&
                        expl != '–') ...[
                      const SizedBox(height: 4),
                      Text(
                        expl,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            theme.textSmall(color: theme.defaultGray500Color),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  labels.unpaidStatus,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textMini(color: statusColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPaymentDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }
}
