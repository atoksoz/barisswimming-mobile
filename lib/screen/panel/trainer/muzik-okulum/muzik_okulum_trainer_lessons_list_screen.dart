import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/common/trainer_self_employee_service.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/core/widgets/trainer_date_filter_field.dart';
import 'package:e_sport_life/core/widgets/trainer_group_lesson_schedule_card.dart';
import 'package:e_sport_life/data/model/muzik_okulum/trainer/trainer_employee_muzik_card_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Yoklamalar — Randevu `v2/me/employee/lessons` (`output.lessons`).
///
/// Üst bar / alt nav: ders programı ile aynı; kartlar grup ders programı kart görünümüyle uyumlu,
/// öğretmen satırı yok — katılımcı listesi ve yoklama durumu gösterilir.
class MuzikOkulumTrainerLessonsListScreen extends StatefulWidget {
  const MuzikOkulumTrainerLessonsListScreen({super.key});

  @override
  State<MuzikOkulumTrainerLessonsListScreen> createState() =>
      _MuzikOkulumTrainerLessonsListScreenState();
}

class _MuzikOkulumTrainerLessonsListScreenState
    extends State<MuzikOkulumTrainerLessonsListScreen> {
  bool _loading = false;
  List<TrainerEmployeeLessonSessionModel> _sessions = [];
  late String _dateFrom;
  late String _dateTo;
  TextEditingController? _dateFromController;
  TextEditingController? _dateToController;

  /// Hot reload `initState` çalıştırmadığı için controller’lar tembel oluşturulur.
  TextEditingController get _fromCtrl {
    _dateFromController ??=
        TextEditingController(text: _displayDayMonthYear(_dateFrom));
    return _dateFromController!;
  }

  TextEditingController get _toCtrl {
    _dateToController ??=
        TextEditingController(text: _displayDayMonthYear(_dateTo));
    return _dateToController!;
  }

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _dateFrom = _iso(n);
    _dateTo = _iso(n.add(const Duration(days: 14)));
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  @override
  void dispose() {
    _dateFromController?.dispose();
    _dateToController?.dispose();
    super.dispose();
  }

  /// API sorgusu (`start` / `end`) için `yyyy-MM-dd`.
  String _iso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Alanlarda gösterim: `dd-MM-yyyy` (ISO `yyyy-MM-dd` giriş).
  String _displayDayMonthYear(String isoYmd) {
    final d = DateTime.tryParse(isoYmd);
    if (d == null) return isoYmd;
    return '${d.day.toString().padLeft(2, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.year}';
  }

  Future<void> _fetch() async {
    final base =
        context.read<ExternalApplicationsConfigCubit>().state?.onlineReservation;
    if (base == null || base.isEmpty) {
      if (mounted) setState(() => _sessions = []);
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await TrainerSelfEmployeeService.fetchLessons(
        randevuApiUrl: base,
        start: _dateFrom,
        end: _dateTo,
      );
      if (!mounted) return;
      if (res.isSuccess) {
        setState(() {
          _sessions =
              TrainerEmployeeLessonSessionModel.sessionsFromOutput(res.output);
          _loading = false;
        });
      } else {
        setState(() {
          _sessions = [];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _sessions = [];
          _loading = false;
        });
      }
    }
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final theme = BlocTheme.theme;
    final initial =
        DateTime.tryParse(isFrom ? _dateFrom : _dateTo) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(nowYear() - 1),
      lastDate: DateTime(nowYear() + 2),
      locale: const Locale('tr', 'TR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: theme.default500Color,
              ),
            ),
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: theme.default500Color,
                  onPrimary: theme.defaultBlackColor,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    final s = _iso(picked);
    setState(() {
      if (isFrom) {
        _dateFrom = s;
        _fromCtrl.text = _displayDayMonthYear(s);
      } else {
        _dateTo = s;
        _toCtrl.text = _displayDayMonthYear(s);
      }
    });
    _fetch();
  }

  int nowYear() => DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

    final title = labels.trainerCardQuickMyLessons.replaceAll('\n', ' ');

    return Scaffold(
      appBar: TopAppBarWidget(title: title),
      backgroundColor: theme.defaultBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: theme.panelPagePadding.left,
              right: theme.panelPagePadding.right,
              top: theme.panelHomeBlockGap,
              bottom: theme.panelHomeBlockGap,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TrainerDateFilterField(
                    theme: theme,
                    variant: TrainerDateFilterFieldVariant.startPrimaryFilled,
                    caption: labels.trainerLessonsListDateFromCaption,
                    controller: _fromCtrl,
                    onTap: () => _pickDate(isFrom: true),
                  ),
                ),
                SizedBox(width: theme.panelSectionSpacing / 2),
                Expanded(
                  child: TrainerDateFilterField(
                    theme: theme,
                    variant: TrainerDateFilterFieldVariant.endAccentBorderWhiteFill,
                    caption: labels.trainerLessonsListDateToCaption,
                    controller: _toCtrl,
                    onTap: () => _pickDate(isFrom: false),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetch,
              child: _loading
                  ? const Center(
                      child: LoadingIndicatorWidget(),
                    )
                  : _sessions.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: theme.panelPagePadding,
                          children: [
                            NoDataTextWidget(text: labels.trainerCardNoData),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                            bottom: theme.panelSectionSpacing,
                          ),
                          itemCount: _sessions.length,
                          itemBuilder: (context, i) =>
                              TrainerDeliveredLessonSessionCard(
                                theme: theme,
                                labels: labels,
                                session: _sessions[i],
                                outerMargin:
                                    EdgeInsetsDirectional.fromSTEB(
                                  theme.panelPagePadding.left,
                                  0,
                                  theme.panelPagePadding.right,
                                  theme.panelCardSpacing,
                                ),
                              ),
                        ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(tab: NavTab.home),
    );
  }
}
