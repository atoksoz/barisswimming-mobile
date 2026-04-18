import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/contants/application_color.dart';
import 'package:e_sport_life/core/constants/url/randevu_al_url_constants.dart';
import 'package:e_sport_life/core/enums/supported_locale.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/services/swimming_course/trainer_schedule_calendar_service.dart';
import 'package:e_sport_life/core/services/swimming_course/trainer_service_plan_form_service.dart';
import 'package:e_sport_life/core/services/trainer_profile_service.dart';
import 'package:e_sport_life/core/utils/date_format_utils.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/widgets/confirm_dialog_widget.dart';
import 'package:e_sport_life/data/model/trainer_schedule_calendar_event_model.dart';
import 'package:e_sport_life/core/widgets/day_selector_widget.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/core/widgets/trainer_group_lesson_schedule_card.dart';
import 'package:e_sport_life/core/widgets/warning_dialog_widget.dart';
import 'package:e_sport_life/screen/panel/common/attendance/attendance_screen.dart';
import 'package:e_sport_life/screen/panel/trainer/swimming-course/lesson_schedule/swimming_course_trainer_add_lesson_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

typedef _SwimmingCourseLessonFormPopResult = ({
  int saved,
  int failed,
  List<int> savedWeekdays,
  String message,
});

/// Yüzme kursu eğitmen — Randevu takvim verisi, **Grup Dersleri** (`GroupLesson` tab 0) UI kopyası.
class SwimmingCourseTrainerLessonScheduleScreen extends StatefulWidget {
  const SwimmingCourseTrainerLessonScheduleScreen({
    super.key,
    /// 1 = Pazartesi … 7 = Pazar ([DateTime.weekday]). null → bugün.
    this.initialWeekday,
    /// [true] → yoklamada ders seçimi: **bugün** sabit (gün/hafta değişmez), ekle/düzenle/sil yok; karta dokununca seçim döner.
    this.pickLessonForAttendance = false,
  });

  final int? initialWeekday;

  /// Yoklama akışından `Navigator.pop(context, TrainerScheduleCalendarEventModel)` ile sonuç dönmek için.
  final bool pickLessonForAttendance;

  @override
  State<SwimmingCourseTrainerLessonScheduleScreen> createState() =>
      _SwimmingCourseTrainerLessonScheduleScreenState();
}

class _SwimmingCourseTrainerLessonScheduleScreenState
    extends State<SwimmingCourseTrainerLessonScheduleScreen> {
  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime _mondayOfWeekContaining(DateTime ref) {
    final local = _dateOnly(ref);
    return local.subtract(Duration(days: local.weekday - DateTime.monday));
  }

  int _selectedDay = DateTime.now().weekday;
  bool _loading = true;
  int? _employeeId;
  List<TrainerScheduleCalendarEventModel> _events = const [];
  /// Silme isteği sürerken aynı kartın tekrar tetiklenmesini engeller.
  int? _deletingServicePlanId;

  /// Şu an ekranda gösterilen haftanın pazartesi (tarih, yerel 00:00).
  /// Hot reload `initState` çalıştırmadığı için `late` değil, burada başlatılır.
  DateTime _visibleWeekMonday = _mondayOfWeekContaining(DateTime.now());

  bool get _locksToTodayForAttendance => widget.pickLessonForAttendance;

  bool get _isViewingToday {
    final sel = _dateOnly(_selectedCalendarDate());
    final now = _dateOnly(DateTime.now());
    return sel == now;
  }

  @override
  void initState() {
    super.initState();
    if (_locksToTodayForAttendance) {
      _selectedDay = DateTime.now().weekday;
      _visibleWeekMonday = _mondayOfWeekContaining(DateTime.now());
    } else {
      final w = widget.initialWeekday;
      if (w != null && w >= 1 && w <= 7) {
        _selectedDay = w;
      }
    }
    _load();
  }

  @override
  void reassemble() {
    super.reassemble();
    // Hot reload: eski State + alan değişimi sonrası tutarsızlığı gider (LateError vb.).
    if (!_locksToTodayForAttendance) {
      _visibleWeekMonday = _mondayOfWeekContaining(DateTime.now());
    }
  }

  /// Bugünün haftasının pazartesisinden önceki haftalara gidilemez.
  DateTime get _earliestNavigableMonday =>
      _mondayOfWeekContaining(DateTime.now());

  bool get _canGoToPreviousWeek =>
      !_locksToTodayForAttendance &&
      _dateOnly(_visibleWeekMonday).isAfter(_dateOnly(_earliestNavigableMonday));

  Future<void> _shiftVisibleWeek(int deltaWeeks) async {
    if (_locksToTodayForAttendance) return;
    if (deltaWeeks != 1 && deltaWeeks != -1) return;
    if (deltaWeeks < 0 && !_canGoToPreviousWeek) return;
    final nextMonday =
        _visibleWeekMonday.add(Duration(days: 7 * deltaWeeks));
    if (deltaWeeks < 0 &&
        _dateOnly(nextMonday).isBefore(_dateOnly(_earliestNavigableMonday))) {
      return;
    }
    setState(() => _visibleWeekMonday = nextMonday);
    await _load();
  }

  /// Hafta şeridi metni ([_visibleWeekMonday] haftası).
  String get _dateRangeStrip => _computeDateRangeStrip();

  String _monthLocaleName() =>
      AppLabels.currentLocale == SupportedLocale.tr ? 'tr_TR' : 'en_US';

  /// Görünür haftanın Pazartesi–Pazar aralığı (tek hafta).
  String _computeDateRangeStrip() {
    final mon = _dateOnly(_visibleWeekMonday);
    final sun = mon.add(const Duration(days: 6));
    final loc = _monthLocaleName();
    if (mon.month == sun.month && mon.year == sun.year) {
      return '${mon.day} - ${sun.day} ${DateFormat.MMMM(loc).format(sun)} ${DateFormat.y(loc).format(sun)}';
    }
    return '${mon.day} ${DateFormat.MMMM(loc).format(mon)} - ${sun.day} ${DateFormat.MMMM(loc).format(sun)} ${DateFormat.y(loc).format(sun)}';
  }

  /// Seçilen gün adının karşılığı gelen takvim günü (görünür hafta içinde).
  DateTime _selectedCalendarDate() {
    return _dateOnly(_visibleWeekMonday)
        .add(Duration(days: _selectedDay - DateTime.monday));
  }

  String _selectedDateLongFormatted() {
    final target = _selectedCalendarDate();
    final loc = _monthLocaleName();
    return DateFormat('d MMMM yyyy', loc).format(target);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final external = context.read<ExternalApplicationsConfigCubit>().state;
      if (external == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final baseUrl = external.onlineReservation;
      final token = await JwtStorageService.getToken();
      if (token == null || token.isEmpty) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final profile = await TrainerProfileService.fetchProfile(
        randevuApiUrl: baseUrl,
        token: token,
      );
      if (!profile.isSuccess || profile.outputMap == null) {
        if (mounted) {
          setState(() {
            _employeeId = null;
            _events = const [];
            _loading = false;
          });
        }
        return;
      }

      final rawId = profile.outputMap!['id'];
      final empId = rawId is int
          ? rawId
          : int.tryParse(rawId?.toString() ?? '');
      if (empId == null) {
        if (mounted) {
          setState(() {
            _employeeId = null;
            _events = const [];
            _loading = false;
          });
        }
        return;
      }

      final monday = _dateOnly(_visibleWeekMonday);
      final sunday = monday.add(const Duration(days: 6));
      final startStr = DateFormatUtils.formatIsoDate(monday);
      final endStr = DateFormatUtils.formatIsoDate(sunday);

      final url = RandevuAlUrlConstants.getV2ServicePlansCalendarUrl(
        baseUrl,
        start: startStr,
        end: endStr,
      );

      final list = await TrainerScheduleCalendarService.fetchCalendar(
        url: url,
        token: token,
      );

      if (mounted) {
        setState(() {
          _employeeId = empId;
          _events = list;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<TrainerScheduleCalendarEventModel> _eventsForSelectedDay() {
    final weekStart = _dateOnly(_visibleWeekMonday);
    final weekEndExclusive = weekStart.add(const Duration(days: 7));
    return _events.where((e) {
      if (e.isCancelled) return false;
      final s = DateFormatUtils.parseRandevuCalendarEventStartLocal(e.start);
      final day = _dateOnly(s);
      if (s.weekday != _selectedDay) return false;
      return !day.isBefore(weekStart) && day.isBefore(weekEndExclusive);
    }).toList()
      ..sort((a, b) {
        try {
          return DateFormatUtils.parseRandevuCalendarEventStartLocal(a.start)
              .compareTo(DateFormatUtils.parseRandevuCalendarEventStartLocal(b.start));
        } catch (_) {
          return a.start.compareTo(b.start);
        }
      });
  }

  void _onDayChanged(int day) {
    if (_locksToTodayForAttendance) return;
    setState(() => _selectedDay = day);
  }

  void _openAttendanceWithLesson(TrainerScheduleCalendarEventModel data) {
    if (data.servicePlanId <= 0) return;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AttendanceScreen(
          presetAttendanceLesson: data,
        ),
      ),
    );
  }

  /// [MaterialPageRoute<Object?>] — geri tuşu vb. yanlış tip dönse bile Navigator kilitlenmesin.
  Future<void> _handleLessonFormPopResult(Object? raw) async {
    if (raw is! _SwimmingCourseLessonFormPopResult) return;
    final result = raw;
    if (result.saved <= 0 || !mounted) return;
    await _load();
    if (!mounted) return;
    setState(() {
      if (result.savedWeekdays.isNotEmpty) {
        _selectedDay = result.savedWeekdays.first;
      }
    });
    if (!mounted) return;
    await warningDialog(
      context,
      message: result.message,
      path: BlocTheme.theme.attentionSvgPath,
    );
  }

  String _flattenServicePlanApiMessage(ApiResponse res) {
    final body = res.body;
    if (body is Map && body['output'] is Map) {
      final out = Map<dynamic, dynamic>.from(body['output'] as Map);
      final lines = <String>[];
      for (final v in out.values) {
        if (v is List) {
          for (final e in v) {
            final s = e?.toString() ?? '';
            if (s.isNotEmpty) lines.add(s);
          }
        } else {
          final s = v?.toString() ?? '';
          if (s.isNotEmpty) lines.add(s);
        }
      }
      if (lines.isNotEmpty) return lines.join('\n');
    }
    return res.message ?? '';
  }

  Future<void> _onDeleteLesson(TrainerScheduleCalendarEventModel data) async {
    if (data.servicePlanId <= 0 || _deletingServicePlanId != null) return;
    final labels = AppLabels.current;
    final theme = BlocTheme.theme;

    final confirmed = await confirmDialog(
      context,
      message: labels.trainerScheduleDeleteLessonConfirm,
      cancelButtonText: labels.no,
      confirmButtonText: labels.yes,
      cancelButtonColor: theme.defaultRed700Color,
      cancelButtonTextColor: theme.defaultWhiteColor,
      confirmButtonColor: theme.default500Color,
      confirmButtonTextColor: theme.defaultBlackColor,
    );
    if (confirmed != true || !mounted) return;

    final external = context.read<ExternalApplicationsConfigCubit>().state;
    if (external == null) return;
    final baseUrl = external.onlineReservation;
    final token = await JwtStorageService.getToken();
    if (token == null || token.isEmpty || !mounted) return;

    setState(() => _deletingServicePlanId = data.servicePlanId);
    try {
      final res = await TrainerServicePlanFormService.deleteServicePlan(
        randevuBaseUrl: baseUrl,
        servicePlanId: data.servicePlanId,
        token: token,
      );
      if (!mounted) return;
      if (res.isSuccess) {
        if (!mounted) return;
        await warningDialog(
          context,
          message: labels.trainerScheduleLessonDeleted,
          leadingIcon: Icons.check_circle_outline,
        );
        if (!mounted) return;
        await _load();
      } else {
        final detail = _flattenServicePlanApiMessage(res).trim();
        final msg = detail.isNotEmpty
            ? '${labels.trainerScheduleDeleteLessonFailed}\n$detail'
            : labels.trainerScheduleDeleteLessonFailed;
        if (!mounted) return;
        await warningDialog(
          context,
          message: msg,
          path: BlocTheme.theme.attentionSvgPath,
        );
      }
    } finally {
      if (mounted) setState(() => _deletingServicePlanId = null);
    }
  }

  Future<void> _onEditLesson(TrainerScheduleCalendarEventModel data) async {
    if (data.servicePlanId <= 0) return;
    final result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute<Object?>(
        builder: (_) => SwimmingCourseTrainerAddLessonScreen(
          editingServicePlanId: data.servicePlanId,
          editSourceEvent: data,
        ),
      ),
    );
    await _handleLessonFormPopResult(result);
  }

  Future<void> _onAddPressed() async {
    final result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute<Object?>(
        builder: (_) => SwimmingCourseTrainerAddLessonScreen(
          initialWeekday: _selectedDay,
        ),
      ),
    );
    await _handleLessonFormPopResult(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;
    final dayEvents = _eventsForSelectedDay();
    final title = _locksToTodayForAttendance
        ? labels.attendanceSelectLessonTitle
        : labels.groupLessons.replaceAll('\n', ' ');

    return Scaffold(
      appBar: TopAppBarWidget(
        title: title,
        actions: _locksToTodayForAttendance
            ? null
            : [
                IconButton(
                  tooltip: labels.add,
                  onPressed: _onAddPressed,
                  icon: Icon(
                    Icons.add,
                    color: theme.default900Color,
                    size: 36,
                  ),
                ),
              ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(
              top: 10,
              bottom: 10,
              right: 20,
              left: 20,
            ),
            decoration: BoxDecoration(
              color: theme.defaultWhiteColor,
              boxShadow: [
                BoxShadow(
                  blurRadius: 2,
                  blurStyle: BlurStyle.outer,
                  color: ApplicationColor.primaryText,
                  offset: Offset.zero,
                  spreadRadius: 1,
                ),
              ],
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            width: MediaQuery.sizeOf(context).width,
            height: 55,
            child: Row(
              children: [
                IconButton(
                  tooltip: labels.previous,
                  onPressed: _canGoToPreviousWeek
                      ? () => _shiftVisibleWeek(-1)
                      : null,
                  icon: Icon(
                    Icons.chevron_left,
                    color: _canGoToPreviousWeek
                        ? theme.default900Color
                        : theme.defaultGray400Color,
                    size: 28,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      _dateRangeStrip,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textLabel(
                        color: theme.default900Color,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: labels.next,
                  onPressed: _locksToTodayForAttendance
                      ? null
                      : () => _shiftVisibleWeek(1),
                  icon: Icon(
                    Icons.chevron_right,
                    color: _locksToTodayForAttendance
                        ? theme.defaultGray400Color
                        : theme.default900Color,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: DaySelector(
              selectedDay: _selectedDay,
              onDayChanged: _onDayChanged,
              allowDayChange: !_locksToTodayForAttendance,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              top: 0,
              bottom: 10,
              right: 20,
              left: 20,
            ),
            decoration: BoxDecoration(
              color: theme.defaultWhiteColor,
              boxShadow: [
                BoxShadow(
                  blurRadius: 2,
                  blurStyle: BlurStyle.outer,
                  color: ApplicationColor.primaryText,
                  offset: Offset.zero,
                  spreadRadius: 1,
                ),
              ],
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            width: MediaQuery.sizeOf(context).width,
            height: 35,
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    margin: const EdgeInsetsDirectional.fromSTEB(10, 5, 10, 5),
                    width: MediaQuery.sizeOf(context).width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          labels.scheduleListHeaderForDate(
                            _selectedDateLongFormatted(),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textSmall(
                            color: theme.default900Color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: LoadingIndicatorWidget())
                : _employeeId == null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            labels.errorOccurred,
                            textAlign: TextAlign.center,
                            style: theme.textBody(
                              color: theme.defaultGray700Color,
                            ),
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: dayEvents.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.only(bottom: 20),
                                children: [
                                  const SizedBox(height: 120),
                                  Center(
                                    child: NoDataTextWidget(
                                      text: _locksToTodayForAttendance
                                          ? labels.attendanceNoLessonsToday
                                          : null,
                                    ),
                                  ),
                                ],
                              )
                            : _buildGroupLessonStyleList(
                                theme,
                                labels,
                                dayEvents,
                              ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupLessonStyleList(
    BaseTheme theme,
    AppLabels labels,
    List<TrainerScheduleCalendarEventModel> items,
  ) {
    final showAttendanceOnCard =
        _isViewingToday && !_locksToTodayForAttendance;

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final data = items[index];
        final pick = _locksToTodayForAttendance;
        return TrainerGroupLessonScheduleCard(
          data: data,
          theme: theme,
          labels: labels,
          onTap: pick && data.servicePlanId > 0
              ? () => Navigator.of(context).pop(data)
              : null,
          bottomActions: pick
              ? null
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (showAttendanceOnCard && data.servicePlanId > 0)
                      _buildLessonCardAttendancePill(theme, labels, data),
                    const Spacer(),
                    _buildLessonCardEditPill(theme, labels, data),
                    const SizedBox(width: 8),
                    _buildLessonCardDeletePill(theme, labels, data),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildLessonCardAttendancePill(
    BaseTheme theme,
    AppLabels labels,
    TrainerScheduleCalendarEventModel data,
  ) {
    final contentColor = theme.default900Color;
    return Tooltip(
      message: labels.scheduleTakeAttendanceFab,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => _openAttendanceWithLesson(data),
          borderRadius: BorderRadius.circular(
            TrainerGroupLessonScheduleCardStyle.headerPillRadius,
          ),
          child: Container(
            padding: TrainerGroupLessonScheduleCardStyle.headerPillPadding,
            decoration:
                TrainerGroupLessonScheduleCardStyle.headerPillDecoration(
              contentColor,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.fact_check_outlined,
                  size: 14,
                  semanticLabel: labels.scheduleTakeAttendanceFab,
                  color: contentColor,
                ),
                const SizedBox(width: 4),
                Text(
                  labels.scheduleTakeAttendanceFab,
                  style: theme.textSmall(color: contentColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonCardEditPill(
    BaseTheme theme,
    AppLabels labels,
    TrainerScheduleCalendarEventModel data,
  ) {
    final contentColor = theme.default900Color;
    final busy = _deletingServicePlanId == data.servicePlanId;
    return Tooltip(
      message: labels.edit,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: busy ? null : () => _onEditLesson(data),
          borderRadius: BorderRadius.circular(
            TrainerGroupLessonScheduleCardStyle.headerPillRadius,
          ),
          child: Opacity(
            opacity: busy ? 0.45 : 1,
            child: Container(
              padding: TrainerGroupLessonScheduleCardStyle.headerPillPadding,
              decoration:
                  TrainerGroupLessonScheduleCardStyle.headerPillDecoration(
                contentColor,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 14,
                    semanticLabel: labels.edit,
                    color: contentColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    labels.edit,
                    style: theme.textSmall(color: contentColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonCardDeletePill(
    BaseTheme theme,
    AppLabels labels,
    TrainerScheduleCalendarEventModel data,
  ) {
    final contentColor = theme.defaultRed700Color;
    final busy = _deletingServicePlanId == data.servicePlanId;
    return Tooltip(
      message: labels.delete,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: busy || data.servicePlanId <= 0
              ? null
              : () => _onDeleteLesson(data),
          borderRadius: BorderRadius.circular(
            TrainerGroupLessonScheduleCardStyle.headerPillRadius,
          ),
          child: Container(
            padding: TrainerGroupLessonScheduleCardStyle.headerPillPadding,
            decoration:
                TrainerGroupLessonScheduleCardStyle.headerPillDecoration(
              contentColor,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (busy)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: contentColor,
                    ),
                  )
                else
                  Icon(
                    Icons.delete_outline,
                    size: 14,
                    semanticLabel: labels.delete,
                    color: contentColor,
                  ),
                const SizedBox(width: 4),
                Text(
                  labels.delete,
                  style: theme.textSmall(color: contentColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
