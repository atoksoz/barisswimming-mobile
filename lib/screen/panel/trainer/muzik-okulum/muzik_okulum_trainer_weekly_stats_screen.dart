import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/contants/application_color.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/common/trainer_self_employee_service.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/data/model/muzik_okulum/trainer/trainer_employee_muzik_card_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Haftalık ders sayıları (finans içermez).
class MuzikOkulumTrainerWeeklyStatsScreen extends StatefulWidget {
  const MuzikOkulumTrainerWeeklyStatsScreen({super.key});

  @override
  State<MuzikOkulumTrainerWeeklyStatsScreen> createState() =>
      _MuzikOkulumTrainerWeeklyStatsScreenState();
}

class _MuzikOkulumTrainerWeeklyStatsScreenState
    extends State<MuzikOkulumTrainerWeeklyStatsScreen> {
  bool _loading = false;
  TrainerEmployeeWeeklyStatsModel? _stats;

  late DateTime _rangeStart;
  late DateTime _rangeEnd;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _rangeStart = DateTime(now.year, now.month, 1);
    _rangeEnd = DateTime(now.year, now.month + 1, 0);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  String _iso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _fetch() async {
    final base = context.read<ExternalApplicationsConfigCubit>().state?.onlineReservation;
    if (base == null || base.isEmpty) {
      if (mounted) setState(() => _stats = null);
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await TrainerSelfEmployeeService.fetchWeeklyStats(
        randevuApiUrl: base,
        startDate: _iso(_rangeStart),
        endDate: _iso(_rangeEnd),
      );
      if (!mounted) return;
      if (res.isSuccess && res.outputMap != null) {
        final m = TrainerEmployeeWeeklyStatsModel.fromOutputMap(res.outputMap!);
        setState(() {
          _stats = m;
          _loading = false;
        });
      } else {
        setState(() {
          _stats = null;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _stats = null;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

    final title = labels.trainerCardQuickWeeklyStats.replaceAll('\n', ' ');

    return Scaffold(
      appBar: TopAppBarWidget(title: title),
      backgroundColor: theme.defaultBackgroundColor,
      bottomNavigationBar: BottomNavigationBarWidget(tab: NavTab.home),
      body: RefreshIndicator(
        onRefresh: _fetch,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (_loading) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: constraints.maxHeight,
                    child: Center(
                      child: LoadingIndicatorWidget(
                        color: theme.default500Color,
                      ),
                    ),
                  ),
                ],
              );
            }
            if (_stats == null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: theme.panelPagePadding,
                children: [
                  SizedBox(
                    height: constraints.maxHeight,
                    child: Center(
                      child: NoDataTextWidget(
                        text: labels.trainerCardNoData,
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                top: theme.panelHomeBlockGap,
                bottom: theme.panelSectionSpacing,
              ),
              children: _statCardList(theme, labels, _stats!),
            );
          },
        ),
      ),
    );
  }

  /// [MuzikOkulumTrainerLessonsListScreen] + [TrainerDeliveredLessonSessionCard] ile
  /// aynı dış kart, gölge ve alt boşluk; satırlar ayrı kart.
  List<Widget> _statCardList(
    BaseTheme theme,
    AppLabels labels,
    TrainerEmployeeWeeklyStatsModel s,
  ) {
    return [
      _statRowCard(
        theme,
        icon: Icons.calendar_view_week_outlined,
        title: labels.trainerCardWeeklyNormalLessonsLabel,
        value: s.weeklyNormalCount,
      ),
      _statRowCard(
        theme,
        icon: Icons.event_repeat_outlined,
        title: labels.trainerCardWeeklyMakeupLessonsLabel,
        value: s.weeklyMakeupCount,
      ),
      _statRowCard(
        theme,
        icon: Icons.functions_outlined,
        title: labels.trainerCardWeeklyTotalLessonsLabel,
        value: s.weeklyTotalCount,
      ),
    ];
  }

  Widget _statRowCard(
    BaseTheme theme, {
    required IconData icon,
    required String title,
    required int value,
  }) {
    final valueStyle =
        theme.textCounter(color: theme.default900Color);
    final iconSize =
        theme.panelRowIconSizeSmall ;

    final outerPadding = EdgeInsets.all(theme.panelCompactInset * 2);
    final innerPadding =
        EdgeInsets.all(theme.panelCompactInset + theme.panelTightVerticalGap * 2);
    final innerRadius =
        BorderRadius.circular(theme.panelCompactInset + theme.panelTightVerticalGap * 2);

    return Container(
      decoration: BoxDecoration(
        color: ApplicationColor.primaryBoxBackground,
        borderRadius:
            BorderRadius.circular(theme.panelCardRadius),
        boxShadow: [
          BoxShadow(
            color: theme.default900Color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: EdgeInsetsDirectional.only(
        start: theme.panelPagePadding.left,
        end: theme.panelPagePadding.right,
        bottom: theme.panelCardSpacing,
      ),
      padding: outerPadding,
      child: Container(
        width: double.infinity,
        padding: innerPadding,
        decoration: BoxDecoration(
          color: theme.default900Color.withValues(alpha: 0.05),
          borderRadius: innerRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(theme.panelTightVerticalGap * 3),
              decoration: BoxDecoration(
                color: theme.defaultWhiteColor,
                borderRadius: BorderRadius.circular(theme.panelCompactInset),
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: theme.default800Color,
              ),
            ),
            SizedBox(
              height: theme.panelTightVerticalGap * 2,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style:
                        theme.textLabelBold(color: theme.default900Color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: theme.panelCompactInset),
                Text('$value', style: valueStyle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
