import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/config/user-config/user_config_cubit.dart';
import 'package:e_sport_life/core/enums/application_type.dart';
import 'package:e_sport_life/core/enums/service_period_type.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/services/swimming_course/trainer_service_plan_form_service.dart';
import 'package:e_sport_life/core/services/trainer_profile_service.dart';
import 'package:e_sport_life/core/utils/date_format_utils.dart';
import 'package:e_sport_life/core/utils/request_util.dart' show ApiResponse;
import 'package:e_sport_life/core/utils/trainer_lesson_plan_datetime_utils.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/core/widgets/warning_dialog_widget.dart';
import 'package:e_sport_life/data/model/randevu_v2_group_lesson_location_model.dart';
import 'package:e_sport_life/data/model/randevu_v2_service_model.dart';
import 'package:e_sport_life/data/model/common/trainer_schedule_calendar_event_model.dart';
import 'package:e_sport_life/data/model/trainer_service_plan_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Randevu `POST v2/service-plans` — Fitiz `ScheduleLessonDialog` grup gövdesi; eğitmen sabit (token profili).
class SwimmingCourseTrainerAddLessonScreen extends StatefulWidget {
  const SwimmingCourseTrainerAddLessonScreen({
    super.key,
    this.initialWeekday,
    this.editingServicePlanId,
    this.editSourceEvent,
  });

  /// 1 = Pazartesi … 7 = Pazar ([DateTime.weekday]).
  final int? initialWeekday;

  /// Doluysa ekran `GET v2/me/service-plans/{id}` ile doldurulur ve kayıt `PUT` ile yapılır.
  final int? editingServicePlanId;

  /// Düzenlemede GET başarısız veya eksikse form bu takvim satırından doldurulur.
  final TrainerScheduleCalendarEventModel? editSourceEvent;

  @override
  State<SwimmingCourseTrainerAddLessonScreen> createState() =>
      _SwimmingCourseTrainerAddLessonScreenState();
}

class _SwimmingCourseTrainerAddLessonScreenState
    extends State<SwimmingCourseTrainerAddLessonScreen> {
  static const List<double> _durationChoices = [
    0.5,
    1,
    1.5,
    2,
    2.5,
    3,
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _personLimitController = TextEditingController(text: '1');
  final _minLimitController = TextEditingController(text: '1');
  final _notesController = TextEditingController();

  /// 1 = Pazartesi … 7 = Pazar; birden fazla gün (Fitiz çoklu gün).
  final Set<int> _selectedWeekdays = {};
  /// Seçilen her gün için ayrı başlangıç saati (`HH:mm`).
  final Map<int, TextEditingController> _timeByWeekday = {};
  /// Seçilen her gün için süre (saat).
  final Map<int, double> _durationByWeekday = {};
  String? _serviceId;
  int? _locationId;
  ServicePeriodType _period = ServicePeriodType.weekly;

  bool _loadingMeta = true;
  bool _saving = false;
  bool _editPlanLoadFailed = false;
  bool _trackPayment = true;
  int? _employeeId;
  List<RandevuV2ServiceModel> _services = const [];
  List<RandevuV2GroupLessonLocationModel> _locations = const [];

  final ScrollController _weekdayBarScrollController = ScrollController();

  /// [DaySelectorWidget] ile aynı ölçüler (grup dersi gün şeridi).
  static const double _weekdayBarArrowBox = 44;
  static const double _weekdayChipWidth = 80;
  static const double _weekdayChipEndMargin = 10;
  static const double _weekdayBarScrollDelta = 100;
  static const double _editModeWeekdayBarOpacity = 0.55;

  bool get _isEditMode => widget.editingServicePlanId != null;

  static double _snapDurationToChoice(double raw) {
    var best = _durationChoices.first;
    var bestDiff = (raw - best).abs();
    for (final h in _durationChoices) {
      final d = (raw - h).abs();
      if (d < bestDiff) {
        best = h;
        bestDiff = d;
      }
    }
    return best;
  }

  @override
  void initState() {
    super.initState();
    if (!_isEditMode) {
      final w = widget.initialWeekday;
      if (w != null && w >= 1 && w <= 7) {
        _selectedWeekdays.add(w);
      } else {
        _selectedWeekdays.add(DateTime.now().weekday);
      }
      for (final d in _selectedWeekdays.toList()) {
        _ensureScheduleForDay(d);
      }
    }
    _loadMeta();
  }

  /// Şerit ilk yüklemede gövdede olmayabiliyor (`_loadingMeta`); [hasClients] olana kadar frame tekrarlanır.
  void _scheduleScrollWeekdayBarToDay(int day) {
    void attemptScroll(int triesLeft) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_weekdayBarScrollController.hasClients) {
          _scrollWeekdayBarTowardsDay(day);
        } else if (triesLeft > 0) {
          attemptScroll(triesLeft - 1);
        }
      });
    }

    attemptScroll(12);
  }

  /// Yeni ders: seçili / `initialWeekday` gününü görünür alana getirir (bugün seçiliyse bugün görünsün).
  void _scheduleScrollWeekdayBarToPrimarySelection() {
    if (_selectedWeekdays.isEmpty) return;
    final initial = widget.initialWeekday;
    final sortedDays = _selectedWeekdays.toList()..sort();
    final day = (initial != null && initial >= 1 && initial <= 7)
        ? initial
        : sortedDays.first;
    _scheduleScrollWeekdayBarToDay(day);
  }

  void _ensureScheduleForDay(int weekday) {
    if (_timeByWeekday.containsKey(weekday)) return;
    final sorted = _selectedWeekdays.where(_timeByWeekday.containsKey).toList()
      ..sort();
    final templateTime = sorted.isEmpty
        ? '09:00'
        : _timeByWeekday[sorted.first]!.text;
    final templateDur = sorted.isEmpty
        ? 1.0
        : (_durationByWeekday[sorted.first] ?? 1.0);
    _timeByWeekday[weekday] = TextEditingController(text: templateTime);
    _durationByWeekday[weekday] = templateDur;
  }

  void _removeScheduleForDay(int weekday) {
    _timeByWeekday.remove(weekday)?.dispose();
    _durationByWeekday.remove(weekday);
  }

  /// Seçili günler ile saat/süre map'lerini hizalar (hot reload / state drift).
  void _syncScheduleControllersWithSelection() {
    for (final d in _selectedWeekdays.toList()) {
      _ensureScheduleForDay(d);
    }
    for (final d in _timeByWeekday.keys.toList()) {
      if (!_selectedWeekdays.contains(d)) {
        _removeScheduleForDay(d);
      }
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    _syncScheduleControllersWithSelection();
  }

  void _disposeAllWeekdayScheduleState() {
    for (final c in _timeByWeekday.values) {
      c.dispose();
    }
    _timeByWeekday.clear();
    _durationByWeekday.clear();
  }

  @override
  void dispose() {
    _weekdayBarScrollController.dispose();
    _nameController.dispose();
    _disposeAllWeekdayScheduleState();
    _personLimitController.dispose();
    _minLimitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadMeta() async {
    final external = context.read<ExternalApplicationsConfigCubit>().state;
    final userConfig = context.read<UserConfigCubit>().state;
    setState(() => _loadingMeta = true);
    try {
      if (external == null) {
        if (mounted) setState(() => _loadingMeta = false);
        return;
      }
      final baseUrl = external.onlineReservation;
      final token = await JwtStorageService.getToken();
      if (token == null || token.isEmpty) {
        if (mounted) setState(() => _loadingMeta = false);
        return;
      }

      final appType = userConfig?.applicationType ?? ApplicationType.swimmingCourse;
      final appTypeParam = appType.value;

      final profile = await TrainerProfileService.fetchProfile(
        randevuApiUrl: baseUrl,
        token: token,
      );
      int? empId;
      if (profile.isSuccess && profile.outputMap != null) {
        final rawId = profile.outputMap!['id'];
        empId = rawId is int
            ? rawId
            : int.tryParse(rawId?.toString() ?? '');
      }

      final services = await TrainerServicePlanFormService.fetchServices(
        randevuBaseUrl: baseUrl,
        applicationTypeValue: appTypeParam,
        token: token,
      );
      final locations = await TrainerServicePlanFormService.fetchLocations(
        randevuBaseUrl: baseUrl,
        token: token,
      );

      var locationsForState = locations;

      var editFailed = false;
      if (widget.editingServicePlanId != null) {
        final plan = await TrainerServicePlanFormService.fetchServicePlanById(
          randevuBaseUrl: baseUrl,
          servicePlanId: widget.editingServicePlanId!,
          token: token,
        );
        var applied = false;
        if (plan != null &&
            plan.id > 0 &&
            plan.planDatetime.trim().isNotEmpty) {
          applied = _applyLoadedServicePlan(plan, services, locationsForState);
          // GET `v2/me/service-plans/{id}` bazen `group_lesson_location_id` döndürmez;
          // takvim satırı (`editSourceEvent`) düzenleme için yedek kaynak.
          if (applied &&
              plan.groupLessonLocationId == null &&
              widget.editSourceEvent != null) {
            final ev = widget.editSourceEvent!;
            final lid = ev.groupLessonLocationId;
            if (lid != null && lid > 0) {
              locationsForState = _mergeLocationOptionIfMissing(
                apiLocations: locations,
                locationId: lid,
                displayHint: ev.locationName,
              );
              _locationId = lid;
            }
          }
        }
        if (!applied && widget.editSourceEvent != null) {
          applied = _applyLoadedFromCalendarEvent(
            widget.editSourceEvent!,
            services,
            locationsForState,
          );
        }
        editFailed = !applied;
      }

      if (!mounted) return;
      setState(() {
        _employeeId = empId;
        _services = services;
        _locations = locationsForState;
        _editPlanLoadFailed = editFailed;
        _loadingMeta = false;
      });
      if (widget.editingServicePlanId == null) {
        _scheduleScrollWeekdayBarToPrimarySelection();
      }
    } catch (_) {
      if (mounted) setState(() => _loadingMeta = false);
    }
  }

  DateTime? _parsePlanLocal(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    try {
      final normalized = t.contains('T') ? t : t.replaceFirst(' ', 'T');
      return DateTime.parse(normalized).toLocal();
    } catch (_) {
      return null;
    }
  }

  /// Takvimdeki lokasyon `GET …/group-lesson-locations` listesinde yoksa bile seçicide eşleşsin.
  List<RandevuV2GroupLessonLocationModel> _mergeLocationOptionIfMissing({
    required List<RandevuV2GroupLessonLocationModel> apiLocations,
    required int? locationId,
    String? displayHint,
  }) {
    if (locationId == null || locationId <= 0) return apiLocations;
    if (apiLocations.any((l) => l.id == locationId)) return apiLocations;
    final label = (displayHint != null && displayHint.trim().isNotEmpty)
        ? displayHint.trim()
        : '#$locationId';
    return <RandevuV2GroupLessonLocationModel>[
      ...apiLocations,
      RandevuV2GroupLessonLocationModel(id: locationId, name: label),
    ];
  }

  /// [services] / [locations] — açılır listelerde olmayan id’ler null bırakılır.
  bool _applyLoadedServicePlan(
    TrainerServicePlanDetailModel plan,
    List<RandevuV2ServiceModel> services,
    List<RandevuV2GroupLessonLocationModel> locations,
  ) {
    _disposeAllWeekdayScheduleState();
    _selectedWeekdays.clear();

    final local = _parsePlanLocal(plan.planDatetime);
    if (local == null) return false;

    final weekday = local.weekday;
    _selectedWeekdays.add(weekday);
    final hm =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    _timeByWeekday[weekday] = TextEditingController(text: hm);
    _durationByWeekday[weekday] = _snapDurationToChoice(plan.durationHours);

    _nameController.text = plan.servicePlanName;
    _personLimitController.text = plan.personLimit.toString();
    _minLimitController.text = plan.minLimit.toString();
    _notesController.text = plan.explanation?.trim() ?? '';
    _trackPayment = plan.trackPayment;

    final sid = plan.servicesId;
    if (sid != null && sid.isNotEmpty) {
      _serviceId = services.any((s) => s.id == sid) ? sid : null;
    } else {
      _serviceId = null;
    }

    final locId = plan.groupLessonLocationId;
    _locationId = locId != null && locations.any((l) => l.id == locId)
        ? locId
        : null;

    final resolved = plan.resolvePeriod();
    if (resolved != null) {
      _period = resolved;
    }

    _scheduleScrollWeekdayBarToDay(weekday);
    return true;
  }

  /// GET tek plan uçları dönmezse takvim satırından form (kayıt için kullanıcı `services_id` seçebilir).
  bool _applyLoadedFromCalendarEvent(
    TrainerScheduleCalendarEventModel ev,
    List<RandevuV2ServiceModel> services,
    List<RandevuV2GroupLessonLocationModel> locations,
  ) {
    if (ev.start.trim().isEmpty) return false;

    _disposeAllWeekdayScheduleState();
    _selectedWeekdays.clear();

    DateTime startLocal;
    try {
      startLocal =
          DateFormatUtils.parseRandevuCalendarEventStartLocal(ev.start.trim());
    } catch (_) {
      return false;
    }

    final weekday = startLocal.weekday;
    _selectedWeekdays.add(weekday);
    final hm =
        '${startLocal.hour.toString().padLeft(2, '0')}:${startLocal.minute.toString().padLeft(2, '0')}';
    _timeByWeekday[weekday] = TextEditingController(text: hm);

    var durH = 1.0;
    if (ev.durationHours != null && ev.durationHours! > 0) {
      durH = ev.durationHours!;
    } else if (ev.end.trim().isNotEmpty) {
      try {
        final endLocal = DateFormatUtils.parseRandevuCalendarEventEndLocal(
          ev.start.trim(),
          ev.end.trim(),
        );
        if (endLocal.isAfter(startLocal)) {
          durH = endLocal.difference(startLocal).inMinutes / 60.0;
          if (durH <= 0 || durH > 24) durH = 1.0;
        }
      } catch (_) {}
    }
    _durationByWeekday[weekday] = _snapDurationToChoice(durH);

    _nameController.text = ev.title;
    _personLimitController.text = (ev.personLimit ?? 1).toString();
    _minLimitController.text = ev.minLimit.toString();
    _notesController.text = '';
    _trackPayment = true;

    final sid = ev.servicesId;
    if (sid != null && sid.isNotEmpty) {
      _serviceId = services.any((s) => s.id == sid) ? sid : null;
    } else {
      _serviceId = null;
    }

    final locId = ev.groupLessonLocationId;
    _locationId = locId != null && locations.any((l) => l.id == locId)
        ? locId
        : null;

    _period = ServicePeriodType.weekly;

    _scheduleScrollWeekdayBarToDay(weekday);
    return true;
  }

  static final RegExp _timeHm = RegExp(r'^\d{1,2}:\d{2}$');

  ({bool ok, int hour, int minute}) _parseTimeHm(String raw) {
    final t = raw.trim();
    if (!_timeHm.hasMatch(t)) {
      return (ok: false, hour: 0, minute: 0);
    }
    final parts = t.split(':');
    final h = int.tryParse(parts[0]) ?? -1;
    final m = int.tryParse(parts[1]) ?? -1;
    if (h < 0 || h > 23 || m < 0 || m > 59) {
      return (ok: false, hour: 0, minute: 0);
    }
    return (ok: true, hour: h, minute: m);
  }

  Future<void> _pickTimeForWeekday(int weekday) async {
    final c = _timeByWeekday[weekday];
    if (c == null || !mounted) return;
    FocusManager.instance.primaryFocus?.unfocus();

    final labels = AppLabels.current;
    final p = _parseTimeHm(c.text);
    final initial = TimeOfDay(
      hour: p.ok ? p.hour : 9,
      minute: p.ok ? p.minute : 0,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      initialEntryMode: TimePickerEntryMode.dial,
      helpText: labels.trainerScheduleStartTimeLabel,
      cancelText: labels.cancel,
      confirmText: labels.confirm,
    );
    if (picked == null || !mounted) return;

    final text =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    c.text = text;
    setState(() {});
  }

  String? _planDatetimeForWeekday(int weekday) {
    final c = _timeByWeekday[weekday];
    if (c == null) return null;
    final p = _parseTimeHm(c.text);
    if (!p.ok) return null;
    final dt = TrainerLessonPlanDatetimeUtils.nextDateTimeForWeekday(
      weekday: weekday,
      hour: p.hour,
      minute: p.minute,
    );
    return DateFormatUtils.formatSqlDateTime(dt);
  }

  String? _flattenApiError(ApiResponse res) {
    final body = res.body;
    if (body is Map) {
      final extras = body['extras']?.toString().trim();
      if (extras != null && extras.isNotEmpty) return extras;
    }
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
    return res.message;
  }

  Future<void> _save() async {
    final labels = AppLabels.current;
    if (!_formKey.currentState!.validate()) return;
    if (_employeeId == null) {
      await warningDialog(
        context,
        message: labels.trainerScheduleLoadFormFailed,
      );
      return;
    }
    if (_serviceId == null || _serviceId!.isEmpty) {
      await warningDialog(
        context,
        message: labels.trainerScheduleSelectService,
      );
      return;
    }

    if (_selectedWeekdays.isEmpty) {
      await warningDialog(
        context,
        message: labels.trainerScheduleSelectAtLeastOneDay,
      );
      return;
    }

    final personLimit = int.tryParse(_personLimitController.text.trim()) ?? 0;
    if (personLimit < 1) return;

    final minLimit = int.tryParse(_minLimitController.text.trim()) ?? 0;

    final sortedDays = _selectedWeekdays.toList()..sort();
    for (final wd in sortedDays) {
      final c = _timeByWeekday[wd];
      if (c == null || !_parseTimeHm(c.text).ok) {
        await warningDialog(
          context,
          message: labels.trainerScheduleStartTimeHint,
        );
        return;
      }
    }

    setState(() => _saving = true);
    try {
      final external = context.read<ExternalApplicationsConfigCubit>().state;
      if (external == null) return;
      final baseUrl = external.onlineReservation;
      final token = await JwtStorageService.getToken();

      final baseName = _nameController.text.trim();
      final notes = _notesController.text.trim();

      if (widget.editingServicePlanId != null) {
        if (sortedDays.length != 1) {
          if (mounted) {
            await warningDialog(
              context,
              message: labels.trainerScheduleLoadLessonFailed,
            );
          }
          return;
        }
        final wd = sortedDays.single;
        final planDt = _planDatetimeForWeekday(wd);
        if (planDt == null) {
          if (mounted) {
            await warningDialog(
              context,
              message: labels.trainerScheduleStartTimeHint,
            );
          }
          return;
        }
        final durationHours = _durationByWeekday[wd] ?? 1.0;

        final body = <String, dynamic>{
          'service_plan_name': baseName,
          'services_id': _serviceId,
          'employee_id': _employeeId,
          'person_limit': personLimit,
          'plan_datetime': planDt,
          'duration_hours': durationHours,
          'period': _period.apiValue,
          'min_limit': minLimit,
          'track_payment': _trackPayment,
        };
        if (notes.isNotEmpty) {
          body['explanation'] = notes;
        }
        if (_locationId != null) {
          body['group_lesson_location_id'] = _locationId;
        }

        final res = await TrainerServicePlanFormService.updateServicePlan(
          randevuBaseUrl: baseUrl,
          servicePlanId: widget.editingServicePlanId!,
          body: body,
          token: token,
        );

        if (!mounted) return;

        if (res.isSuccess) {
          final summary = labels.trainerScheduleLessonsSaveResult(1, 0);
          Navigator.pop(
            context,
            (
              saved: 1,
              failed: 0,
              savedWeekdays: <int>[wd],
              message: summary,
            ),
          );
          return;
        }

        final err = '${labels.trainerScheduleLessonSaveFailed}\n'
            '${_flattenApiError(res) ?? ''}'.trim();
        if (!mounted) return;
        await warningDialog(context, message: err);
        return;
      }

      var saved = 0;
      var failed = 0;
      ApiResponse? lastErrorRes;
      final savedWeekdays = <int>[];

      for (final wd in sortedDays) {
        final planDt = _planDatetimeForWeekday(wd);
        if (planDt == null) {
          failed++;
          continue;
        }
        final durationHours = _durationByWeekday[wd] ?? 1.0;

        final body = <String, dynamic>{
          'service_plan_name': baseName,
          'services_id': _serviceId,
          'employee_id': _employeeId,
          'person_limit': personLimit,
          'plan_datetime': planDt,
          'duration_hours': durationHours,
          'period': _period.apiValue,
          'min_limit': minLimit,
          'track_payment': _trackPayment,
        };
        if (notes.isNotEmpty) {
          body['explanation'] = notes;
        }
        if (_locationId != null) {
          body['group_lesson_location_id'] = _locationId;
        }

        final res = await TrainerServicePlanFormService.createServicePlan(
          randevuBaseUrl: baseUrl,
          body: body,
          token: token,
        );
        if (res.isSuccess) {
          saved++;
          savedWeekdays.add(wd);
        } else {
          failed++;
          lastErrorRes = res;
        }
      }

      if (!mounted) return;

      final summary = labels.trainerScheduleLessonsSaveResult(saved, failed);
      final errorTail = failed > 0 && lastErrorRes != null
          ? '\n${_flattenApiError(lastErrorRes) ?? ''}'.trim()
          : '';

      final summaryFull = '$summary$errorTail'.trim();

      if (saved == 0) {
        await warningDialog(context, message: summaryFull);
        return;
      }

      Navigator.pop(
        context,
        (
          saved: saved,
          failed: failed,
          savedWeekdays: savedWeekdays,
          message: summaryFull,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _weekdayLabel(int day, AppLabels labels) {
    switch (day) {
      case DateTime.monday:
        return labels.monday;
      case DateTime.tuesday:
        return labels.tuesday;
      case DateTime.wednesday:
        return labels.wednesday;
      case DateTime.thursday:
        return labels.thursday;
      case DateTime.friday:
        return labels.friday;
      case DateTime.saturday:
        return labels.saturday;
      case DateTime.sunday:
        return labels.sunday;
      default:
        return '';
    }
  }

  void _scrollWeekdayBarTowardsDay(int day) {
    if (!_weekdayBarScrollController.hasClients) return;
    final stride = _weekdayChipWidth + _weekdayChipEndMargin;
    final target = (day - 1) * stride;
    final max = _weekdayBarScrollController.position.maxScrollExtent;
    _weekdayBarScrollController.animateTo(
      target.clamp(0.0, max),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// Grup dersi / hızlı randevu [DaySelectorWidget] ile aynı ok + kaydırılabilir gün şeridi.
  Widget _buildWeekdayPickerBar(BaseTheme theme, AppLabels labels) {
    Widget arrowButton({
      required Widget icon,
      required VoidCallback onPressed,
    }) {
      return IconButton(
        onPressed: onPressed,
        icon: Container(
          height: _weekdayBarArrowBox,
          width: _weekdayBarArrowBox,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.defaultWhiteColor,
            border: Border.all(
              color: theme.default900Color,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: icon),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        arrowButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 16,
            color: theme.default900Color,
          ),
          onPressed: () {
            if (!_weekdayBarScrollController.hasClients) return;
            final next = (_weekdayBarScrollController.offset -
                    _weekdayBarScrollDelta)
                .clamp(
              0.0,
              _weekdayBarScrollController.position.maxScrollExtent,
            );
            _weekdayBarScrollController.animateTo(
              next,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _weekdayBarScrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var d = 1; d <= 7; d++)
                  _buildWeekdayChip(d, theme, labels),
              ],
            ),
          ),
        ),
        arrowButton(
          icon: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: theme.default900Color,
          ),
          onPressed: () {
            if (!_weekdayBarScrollController.hasClients) return;
            final next = (_weekdayBarScrollController.offset +
                    _weekdayBarScrollDelta)
                .clamp(
              0.0,
              _weekdayBarScrollController.position.maxScrollExtent,
            );
            _weekdayBarScrollController.animateTo(
              next,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
        ),
      ],
    );
  }

  Widget _buildWeekdayChip(int d, BaseTheme theme, AppLabels labels) {
    final selected = _selectedWeekdays.contains(d);
    final canDeselect = _selectedWeekdays.length > 1;
    return InkWell(
      onTap: () {
        if (selected && !canDeselect) return;
        if (!selected) {
          setState(() {
            _selectedWeekdays.add(d);
            _ensureScheduleForDay(d);
          });
          _scheduleScrollWeekdayBarToDay(d);
        } else {
          setState(() {
            _removeScheduleForDay(d);
            _selectedWeekdays.remove(d);
          });
        }
      },
      child: Container(
        width: _weekdayChipWidth,
        alignment: Alignment.center,
        margin: EdgeInsetsDirectional.only(end: _weekdayChipEndMargin),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? theme.default500Color : theme.defaultWhiteColor,
          border: Border.all(color: theme.defaultGray700Color),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          _weekdayLabel(d, labels),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textCaptionSemiBold(color: theme.default900Color),
        ),
      ),
    );
  }

  /// `TrainerProfileEditScreen._buildTextField` / `_buildGenderDropdown` ile aynı dış boşluk.
  Widget _profilePaddedField(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: child,
    );
  }

  List<Widget> _scheduleRowsForSelectedDays(BaseTheme theme, AppLabels labels) {
    _syncScheduleControllersWithSelection();
    final days = _selectedWeekdays.toList()..sort();
    return [
      for (final d in days)
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Container(
            width: double.infinity,
            padding: theme.panelCardInnerPadding,
            decoration: BoxDecoration(
              color: theme.defaultWhiteColor,
              borderRadius: BorderRadius.circular(theme.panelCardRadius),
              border: Border.all(color: theme.defaultGray200Color),
              boxShadow: [
                BoxShadow(
                  color: theme.default900Color.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.event_repeat_outlined,
                      size: 20,
                      color: theme.default700Color,
                    ),
                    SizedBox(width: theme.panelHomeBlockGap),
                    Expanded(
                      child: Text(
                        _weekdayLabel(d, labels),
                        style: theme.textLabel(color: theme.default900Color),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: theme.panelHomeBlockGap),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _timeByWeekday[d]!,
                        readOnly: true,
                        onTap: () => _pickTimeForWeekday(d),
                        showCursor: false,
                        enableInteractiveSelection: false,
                        cursorColor: theme.defaultBlackColor,
                        style: theme.inputTextStyle(),
                        decoration: theme
                            .inputDecoration(
                              labelText:
                                  labels.trainerScheduleDayStartTimeShortLabel,
                              hintText: labels.trainerSchedulePickTimeFieldHint,
                            )
                            .copyWith(
                              suffixIcon: IconButton(
                                tooltip: labels.trainerSchedulePickTimeTooltip,
                                onPressed: () => _pickTimeForWeekday(d),
                                icon: Icon(
                                  Icons.schedule_outlined,
                                  color: theme.default700Color,
                                ),
                              ),
                            ),
                        validator: (v) {
                          if (v == null || !_parseTimeHm(v).ok) {
                            return labels.trainerScheduleStartTimeHint;
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: theme.panelHomeBlockGap),
                    Expanded(
                      child: DropdownButtonFormField<double>(
                        value: _durationByWeekday[d] ?? 1.0,
                        style: theme.inputTextStyle(),
                        dropdownColor: theme.defaultWhiteColor,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: theme.defaultBlackColor,
                        ),
                        decoration: theme.inputDecoration(
                          labelText: labels.trainerScheduleDurationLabel,
                        ),
                        items: _durationChoices
                            .map(
                              (h) => DropdownMenuItem<double>(
                                value: h,
                                child: Text(
                                  '$h',
                                  style: theme.inputTextStyle(),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _durationByWeekday[d] = v);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;
    final gap = theme.panelCardSpacing;
    final sectionGap = theme.panelSectionSpacing;

    return Scaffold(
      backgroundColor: theme.panelCardBackground,
      appBar: TopAppBarWidget(
        title: _isEditMode
            ? labels.trainerScheduleEditLessonTitle
            : labels.trainerScheduleAddLessonTitle,
      ),
      body: _loadingMeta
          ? const Center(child: LoadingIndicatorWidget())
          : _isEditMode && _editPlanLoadFailed
              ? Center(
                  child: Padding(
                    padding: theme.panelPagePadding,
                    child: Text(
                      labels.trainerScheduleLoadLessonFailed,
                      textAlign: TextAlign.center,
                      style: theme.textBody(color: theme.defaultGray700Color),
                    ),
                  ),
                )
          : _employeeId == null
              ? Center(
                  child: Padding(
                    padding: theme.panelPagePadding,
                    child: Text(
                      labels.trainerScheduleLoadFormFailed,
                      textAlign: TextAlign.center,
                      style: theme.textBody(color: theme.defaultGray700Color),
                    ),
                  ),
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: theme.panelPagePadding.copyWith(
                      top: 12,
                      bottom: 32,
                    ),
                    children: [
                      _TrainerScheduleHintBanner(text: labels.trainerScheduleTrainerFixedHint),
                      SizedBox(height: sectionGap),
                      _SectionCard(
                        title: labels.trainerScheduleSectionEssentials,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _profilePaddedField(
                              DropdownButtonFormField<String?>(
                                value: _serviceId,
                                isExpanded: true,
                                style: theme.inputTextStyle(),
                                dropdownColor: theme.defaultWhiteColor,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: theme.defaultBlackColor,
                                ),
                                decoration: theme.inputDecoration(
                                  labelText: labels.trainerScheduleServiceTypeLabel,
                                ),
                                items: [
                                  DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text(
                                      labels.trainerScheduleSelectService,
                                      style: theme.inputTextStyle(
                                        color: theme.defaultGray700Color,
                                      ),
                                    ),
                                  ),
                                  ..._services.map(
                                    (s) => DropdownMenuItem<String?>(
                                      value: s.id,
                                      child: Text(
                                        s.name.isNotEmpty ? s.name : s.id,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.inputTextStyle(),
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (v) {
                                  setState(() {
                                    _serviceId = v;
                                    if (v != null && v.isNotEmpty) {
                                      for (final s in _services) {
                                        if (s.id == v) {
                                          _nameController.text =
                                              s.name.isNotEmpty ? s.name : s.id;
                                          break;
                                        }
                                      }
                                    }
                                  });
                                },
                              ),
                            ),
                            _profilePaddedField(
                              TextFormField(
                                controller: _nameController,
                                cursorColor: theme.defaultBlackColor,
                                style: theme.inputTextStyle(),
                                decoration: theme.inputDecoration(
                                  labelText: labels.trainerScheduleLessonNameLabel,
                                ),
                                textCapitalization: TextCapitalization.sentences,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return labels.fieldCannotBeEmpty;
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: gap),
                      _SectionCard(
                        title: labels.trainerScheduleSectionSchedule,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _profilePaddedField(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    labels.trainerScheduleLessonDaysLabel,
                                    style: theme.textLabel(
                                      color: theme.default900Color,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    _isEditMode
                                        ? labels.trainerScheduleEditLessonDaysHint
                                        : labels.trainerScheduleLessonDaysHint,
                                    style: theme.textSmallNormal(
                                      color: theme.defaultGray700Color,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  IgnorePointer(
                                    ignoring: _isEditMode,
                                    child: Opacity(
                                      opacity: _isEditMode
                                          ? _editModeWeekdayBarOpacity
                                          : 1,
                                      child: _buildWeekdayPickerBar(theme, labels),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_selectedWeekdays.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 14, 10, 6),
                                child: Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(
                                    labels.trainerScheduleDayTimeSlotsTitle,
                                    style: theme.textSmall(
                                      color: theme.default700Color,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            ..._scheduleRowsForSelectedDays(theme, labels),
                            _profilePaddedField(
                              DropdownButtonFormField<ServicePeriodType>(
                                value: _period,
                                style: theme.inputTextStyle(),
                                dropdownColor: theme.defaultWhiteColor,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: theme.defaultBlackColor,
                                ),
                                decoration: theme.inputDecoration(
                                  labelText: labels.trainerSchedulePeriodLabel,
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: ServicePeriodType.weekly,
                                    child: Text(
                                      labels.trainerSchedulePeriodWeekly,
                                      style: theme.inputTextStyle(),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: ServicePeriodType.oneTime,
                                    child: Text(
                                      labels.trainerSchedulePeriodOneTime,
                                      style: theme.inputTextStyle(),
                                    ),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v != null) setState(() => _period = v);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: gap),
                      _SectionCard(
                        title: labels.trainerScheduleSectionLimits,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _profilePaddedField(
                                TextFormField(
                                  controller: _personLimitController,
                                  cursorColor: theme.defaultBlackColor,
                                  style: theme.inputTextStyle(),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: theme.inputDecoration(
                                    labelText:
                                        labels.trainerSchedulePersonLimitLabel,
                                  ),
                                  validator: (v) {
                                    final n = int.tryParse(v?.trim() ?? '') ?? 0;
                                    if (n < 1) return labels.fieldCannotBeEmpty;
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: _profilePaddedField(
                                TextFormField(
                                  controller: _minLimitController,
                                  cursorColor: theme.defaultBlackColor,
                                  style: theme.inputTextStyle(),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: theme.inputDecoration(
                                    labelText: labels.minParticipation,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: gap),
                      _SectionCard(
                        title: labels.trainerScheduleSectionMore,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _profilePaddedField(
                              DropdownButtonFormField<int?>(
                                value: _locationId,
                                isExpanded: true,
                                style: theme.inputTextStyle(),
                                dropdownColor: theme.defaultWhiteColor,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: theme.defaultBlackColor,
                                ),
                                decoration: theme.inputDecoration(
                                  labelText: labels.location,
                                ),
                                selectedItemBuilder: (context) => [
                                  Text(
                                    labels.trainerScheduleNoLocationOption,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.inputTextStyle(
                                      color: theme.defaultGray700Color,
                                    ),
                                  ),
                                  ..._locations.map(
                                    (l) => Text(
                                      l.displayLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.inputTextStyle(),
                                    ),
                                  ),
                                ],
                                items: [
                                  DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text(
                                      labels.trainerScheduleNoLocationOption,
                                      style: theme.inputTextStyle(
                                        color: theme.defaultGray700Color,
                                      ),
                                    ),
                                  ),
                                  ..._locations.map(
                                    (l) => DropdownMenuItem<int?>(
                                      value: l.id,
                                      child: Text(
                                        l.displayLabel,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.inputTextStyle(),
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (v) =>
                                    setState(() => _locationId = v),
                              ),
                            ),
                            _profilePaddedField(
                              TextFormField(
                                controller: _notesController,
                                cursorColor: theme.defaultBlackColor,
                                style: theme.inputTextStyle(),
                                minLines: 3,
                                maxLines: 6,
                                decoration: theme.inputDecoration(
                                  labelText: labels.description,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: sectionGap),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saving ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.default500Color,
                              foregroundColor: theme.defaultWhiteColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              disabledBackgroundColor:
                                  theme.default500Color.withValues(alpha: 0.6),
                            ),
                            child: _saving
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            theme.defaultWhiteColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        labels.saving,
                                        style: theme.textBody(
                                          color: theme.defaultWhiteColor,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    labels.save,
                                    style: theme.textBody(
                                      color: theme.defaultBlackColor,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    return Container(
      width: double.infinity,
      decoration: theme.panelCardDecoration,
      padding: theme.panelCardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.panelTitleStyle,
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _TrainerScheduleHintBanner extends StatelessWidget {
  const _TrainerScheduleHintBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: theme.defaultWhiteColor,
        borderRadius: BorderRadius.circular(theme.panelCardRadius),
        border: Border.all(color: theme.defaultGray200Color),
        boxShadow: [
          BoxShadow(
            color: theme.default900Color.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 22,
            color: theme.default700Color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textSmallNormal(color: theme.defaultGray700Color),
            ),
          ),
        ],
      ),
    );
  }
}
