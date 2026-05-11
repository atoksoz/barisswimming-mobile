import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/core/services/muzik_okulum/trainer/trainer_enrollment_package_service.dart';
import 'package:e_sport_life/data/model/muzik_okulum/trainer/trainer_enrollment_package_option_model.dart';
import 'package:e_sport_life/core/utils/date_format_utils.dart';
import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/constants/reservation_attendance.dart';
import 'package:e_sport_life/core/constants/trainer_package_option_situation.dart';
import 'package:e_sport_life/core/constants/trainer_roster_burn_ui_phase.dart';
import 'package:e_sport_life/core/constants/url/randevu_al_url_constants.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/services/common/trainer_schedule_calendar_service.dart';
import 'package:e_sport_life/core/services/muzik_okulum/trainer/trainer_service_plan_bulk_attendance_service.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/core/widgets/trainer_group_lesson_schedule_card.dart';
import 'package:e_sport_life/core/widgets/warning_dialog_widget.dart';
import 'package:e_sport_life/screen/panel/trainer/common/lesson_schedule/trainer_lesson_schedule_participants_dialog.dart';
import 'package:e_sport_life/data/model/common/trainer_calendar_enrollment_row_model.dart';
import 'package:e_sport_life/data/model/common/trainer_calendar_reservation_row_model.dart';
import 'package:e_sport_life/data/model/common/trainer_schedule_calendar_event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Fitiz `schedule/attendance` — tek ders kartı: kayıtlı öğrenciler + geldi / yak / yakma iptali.
///
/// Görünüm: [TrainerLessonScheduleScreen] ile aynı üst bar + grup ders kartı dili.
class MuzikOkulumTrainerLessonRosterAttendanceScreen extends StatefulWidget {
  const MuzikOkulumTrainerLessonRosterAttendanceScreen({
    super.key,
    required this.initialEvent,
  });

  final TrainerScheduleCalendarEventModel initialEvent;

  @override
  State<MuzikOkulumTrainerLessonRosterAttendanceScreen> createState() =>
      _MuzikOkulumTrainerLessonRosterAttendanceScreenState();
}

class _MuzikOkulumTrainerLessonRosterAttendanceScreenState
    extends State<MuzikOkulumTrainerLessonRosterAttendanceScreen> {
  /// Yerleşim — tema ile örtüşmeyen birkaç sabit (magic sayı yasağı).
  static const double _emptyStateMinHeight = 200;
  static const double _saveSpinnerSize = 20;
  static const double _iconHitMinSide = 40;
  static const double _listBottomPadding = 24;
  /// [BottomNavigationBarWidget] (GNav) yüksekliği + dış boşluklara rezerv.
  static const double _bottomTabBarReserve = 110;

  /// Son öğrenci kartı ile Kaydet arası (üye profili davranışına paralel sabit boşluk).
  static const double _saveBelowLastCardGap = 20;
  static const double _packageInlineLoaderSize = 14;
  static const double _packageInlineLoaderStrokeWidth = 2;
  /// [TrainerGroupLessonScheduleCard] öğretmen satırı ile aynı avatar ölçüsü.
  static const double _studentHeaderAvatarRadius = 20;
  /// Müzik okulu üye paneli ödeme planı / paket durum rozeti ile aynı görünüm (chip).
  static const double _presentAttendanceBadgeRadius = 8;
  static const double _presentAttendanceBadgeBgOpacity = 0.12;
  TrainerScheduleCalendarEventModel? _event;
  bool _loading = true;
  bool _saving = false;
  final Map<int, bool> _presentByUserId = {};
  final Set<int> _pendingBurns = {};
  final Set<int> _pendingUnburns = {};

  /// Kayıt id → Randevu paket seçenekleri (api-system özeti).
  final Map<int, TrainerEnrollmentPackageOptionsOutputModel> _packageOptionsByEnrollmentId =
      {};
  final Set<int> _packageOptionsLoading = {};

  /// Aynı enrollment için yükleme tekrar kuyruğa alınmasın — await öncesi senkron set.
  final Set<int> _packageOptionFetchStartedIds = {};

  /// Kaydet ile PATCH edilecek üyelik paketi (`enrollment.id` → `member_register_id`).
  final Map<int, int> _pendingMemberRegisterByEnrollmentId = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  /// Hızlı randevu saat kartları ile hizalı yüzey ([theme.panelCardBackground]).
  static BoxDecoration _hizliRandevuListItemDecoration(BaseTheme theme) {
    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          spreadRadius: 1,
          color: theme.panelDividerColor,
        ),
      ],
      color: theme.panelCardBackground,
      border: Border.all(color: theme.panelDividerColor),
      borderRadius: BorderRadius.circular(theme.panelLargeRadius),
    );
  }

  String _lessonDateYmd(TrainerScheduleCalendarEventModel e) {
    final d = DateFormatUtils.parseRandevuCalendarEventStartLocal(e.start);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  bool _isBurned(int attendance) =>
      attendance == ReservationAttendanceValue.burned;

  bool _isPresent(int attendance) =>
      attendance == ReservationAttendanceValue.attended;

  bool _serverBurnedForUser(int userId) {
    final list = _event?.reservations ?? const <TrainerCalendarReservationRowModel>[];
    final r = _reservationForUserFromList(list, userId);
    return r != null && _isBurned(r.attendance);
  }

  TrainerRosterBurnUiPhase _burnUiPhase(int userId) {
    final uid = userId;
    final serverBurned = _serverBurnedForUser(uid);
    if (serverBurned && _pendingUnburns.contains(uid)) {
      return TrainerRosterBurnUiPhase.pendingUnburn;
    }
    if (serverBurned) return TrainerRosterBurnUiPhase.burned;
    if (_pendingBurns.contains(uid)) return TrainerRosterBurnUiPhase.pendingBurn;
    return TrainerRosterBurnUiPhase.normal;
  }

  bool _canMarkBurn(int userId) {
    if (_burnUiPhase(userId) != TrainerRosterBurnUiPhase.normal) return false;
    if (!_packageActionsAllowedForUserId(userId)) return false;
    return !(_presentByUserId[userId] ?? false);
  }

  /// Takvim bazen üye adresi olmadan veya isimsiz enrollment döndürür; bu satırlar kart üretmez.
  bool _isVisibleRosterEnrollment(TrainerCalendarEnrollmentRowModel en) {
    final uid = en.userId;
    if (uid == null) return false;
    if (en.memberName.trim().isEmpty) return false;
    return true;
  }

  /// Görünür kayıtlar; aynı [TrainerCalendarEnrollmentRowModel.userId] tekrarında ilki kullanılır.
  List<TrainerCalendarEnrollmentRowModel> _visibleEnrollmentsForEvent(
    TrainerScheduleCalendarEventModel e,
  ) {
    final seenUserIds = <int>{};
    final out = <TrainerCalendarEnrollmentRowModel>[];
    for (final en in e.enrollments) {
      if (!_isVisibleRosterEnrollment(en)) continue;
      final uid = en.userId!;
      if (seenUserIds.contains(uid)) continue;
      seenUserIds.add(uid);
      out.add(en);
    }
    return out;
  }

  TrainerCalendarEnrollmentRowModel? _enrollmentRowForUserId(int userId) {
    final evt = _event;
    if (evt == null) return null;
    for (final en in _visibleEnrollmentsForEvent(evt)) {
      if (en.userId == userId) return en;
    }
    return null;
  }

  int? _effectiveMemberRegisterId(TrainerCalendarEnrollmentRowModel en) {
    return _pendingMemberRegisterByEnrollmentId[en.id] ?? en.memberRegisterId;
  }

  /// Pasif değil ve (kalan hak bilinmiyor veya sıfırdan büyük).
  bool _packageOptionAllowsAttendance(TrainerEnrollmentPackageOptionModel o) {
    if (!TrainerPackageOptionSituation.allowsAttendanceActions(o.situation)) {
      return false;
    }
    final r = o.remainingQty;
    if (r != null && r <= 0) return false;
    return true;
  }

  TrainerEnrollmentPackageOptionModel? _selectedPackageOptionForEnrollment(
    TrainerCalendarEnrollmentRowModel en,
  ) {
    final data = _packageOptionsByEnrollmentId[en.id];
    final opts = data?.options ?? [];
    if (opts.isEmpty) return null;
    final effectiveId = _effectiveMemberRegisterId(en);
    if (effectiveId == null) return null;
    for (final o in opts) {
      if (o.memberRegisterId == effectiveId) return o;
    }
    return opts.first;
  }

  /// Üyelik seçenekleri yok veya seçili paket yoklama / yakmaya uygun değilse kapalı.
  bool _canOperatePackageActions(TrainerCalendarEnrollmentRowModel en) {
    if (en.memberRegisterId == null) return false;
    if (_packageOptionsLoading.contains(en.id)) return false;
    if (!_packageOptionsByEnrollmentId.containsKey(en.id)) return false;
    final selected = _selectedPackageOptionForEnrollment(en);
    if (selected == null) return false;
    return _packageOptionAllowsAttendance(selected);
  }

  bool _packageActionsAllowedForUserId(int userId) {
    final en = _enrollmentRowForUserId(userId);
    if (en == null) return false;
    return _canOperatePackageActions(en);
  }

  void _applyEvent(TrainerScheduleCalendarEventModel e) {
    final map = <int, bool>{};
    for (final en in _visibleEnrollmentsForEvent(e)) {
      final uid = en.userId!;
      final res = _reservationForUserFromList(e.reservations, uid);
      map[uid] = res != null && _isPresent(res.attendance);
    }
    setState(() {
      _event = e;
      _presentByUserId
        ..clear()
        ..addAll(map);
      _pendingBurns.clear();
      _pendingUnburns.clear();
      _packageOptionsByEnrollmentId.clear();
      _packageOptionsLoading.clear();
      _packageOptionFetchStartedIds.clear();
      _pendingMemberRegisterByEnrollmentId.clear();
    });
  }

  TrainerCalendarReservationRowModel? _reservationForUserFromList(
    List<TrainerCalendarReservationRowModel> list,
    int userId,
  ) {
    for (final r in list) {
      if (r.userId == userId) return r;
    }
    return null;
  }

  Future<void> _load({bool showFullScreenLoading = true}) async {
    final external = context.read<ExternalApplicationsConfigCubit>().state;
    if (external == null) {
      _applyEvent(widget.initialEvent);
      if (mounted && showFullScreenLoading) {
        setState(() => _loading = false);
      }
      return;
    }
    final base = external.onlineReservation;
    final token = await JwtStorageService.getToken();
    if (!mounted) return;
    if (token == null || token.isEmpty) {
      _applyEvent(widget.initialEvent);
      if (mounted && showFullScreenLoading) {
        setState(() => _loading = false);
      }
      return;
    }

    if (showFullScreenLoading) {
      setState(() => _loading = true);
    }
    try {
      final ymd = _lessonDateYmd(widget.initialEvent);
      final url = RandevuAlUrlConstants.getV2ServicePlansCalendarUrl(
        base,
        start: ymd,
        end: ymd,
      );
      final list =
          await TrainerScheduleCalendarService.fetchCalendar(url: url, token: token);
      final match = _pickMatchingEvent(list, widget.initialEvent);
      if (!mounted) return;
      if (match != null) {
        _applyEvent(match);
      } else {
        _applyEvent(widget.initialEvent);
      }
    } catch (_) {
      if (mounted) _applyEvent(widget.initialEvent);
    } finally {
      if (mounted && showFullScreenLoading) {
        setState(() => _loading = false);
      }
    }
  }

  TrainerScheduleCalendarEventModel? _pickMatchingEvent(
    List<TrainerScheduleCalendarEventModel> list,
    TrainerScheduleCalendarEventModel target,
  ) {
    final t0 = DateFormatUtils.parseRandevuCalendarEventStartLocal(target.start);
    for (final e in list) {
      if (e.servicePlanId != target.servicePlanId) continue;
      final t = DateFormatUtils.parseRandevuCalendarEventStartLocal(e.start);
      if (t.year == t0.year && t.month == t0.month && t.day == t0.day) {
        return e;
      }
    }
    return null;
  }

  Widget _buildPackageUnavailableHint(BaseTheme theme, AppLabels labels) {
    return Padding(
      padding: EdgeInsets.only(top: theme.panelTightVerticalGap * 2),
      child: Text(
        labels.trainerServicePlanRosterPackageUnavailableHint,
        style: theme.textCaption(color: theme.defaultGray500Color),
      ),
    );
  }

  Widget _buildPackageHintLine(BaseTheme theme, String message) {
    return Padding(
      padding: EdgeInsets.only(top: theme.panelTightVerticalGap * 2),
      child: Text(
        message,
        style: theme.textCaption(color: theme.defaultGray500Color),
      ),
    );
  }

  /// [TrainerGroupLessonScheduleCard] içindeki ders saati / kontenjan kutusu ile aynı yüzey.
  Widget _lessonScheduleCardStyleInfoPanel(BaseTheme theme, Widget child) {
    return Container(
      width: double.infinity,
      padding: theme.panelCardInnerPadding,
      decoration: BoxDecoration(
        color: theme.default900Color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(theme.panelCardInnerRadius),
      ),
      child: child,
    );
  }

  /// [TrainerGroupLessonScheduleCard] `_InfoItem` ile aynı düzen (ikon kutusu + etiket + değer).
  Widget _groupLessonScheduleStyleInfoRow(
    BaseTheme theme, {
    required IconData icon,
    required String label,
    required String value,
    int valueMaxLines = 2,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(theme.panelCompactInset - 2),
          decoration: BoxDecoration(
            color: theme.defaultWhiteColor,
            borderRadius: BorderRadius.circular(theme.panelCompactInset),
          ),
          child: Icon(
            icon,
            size: 16,
            color: theme.default800Color,
          ),
        ),
        SizedBox(width: theme.panelInlineLeadingGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textMini(
                  color: theme.default900Color.withValues(alpha: 0.5),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: theme.textSmall(color: theme.default900Color),
                maxLines: valueMaxLines,
                overflow: TextOverflow.ellipsis,
                softWrap: valueMaxLines > 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPackageDetailsColumn(
    BaseTheme theme,
    AppLabels labels,
    TrainerEnrollmentPackageOptionModel o, {
    required bool includePackageNameRow,
  }) {
    final gap = SizedBox(height: theme.panelCompactInset + 2);
    final name = o.name.trim().isEmpty ? '—' : o.name.trim();
    final sd = DateFormatUtils.formatDayMonthYearDots(o.startDate);
    final ed = DateFormatUtils.formatDayMonthYearDots(o.endDate);

    final String dateValue;
    if (sd.isNotEmpty && ed.isNotEmpty) {
      dateValue = '$sd - $ed';
    } else if (sd.isNotEmpty) {
      dateValue = sd;
    } else if (ed.isNotEmpty) {
      dateValue = ed;
    } else {
      dateValue = '';
    }

    final rem = o.remainingQty;
    final remStr = rem != null ? '$rem' : labels.summaryValueNone;
    final isActive =
        TrainerPackageOptionSituation.allowsAttendanceActions(o.situation);
    final statusText = isActive ? labels.activeStatus : labels.passiveStatus;

    final children = <Widget>[];

    if (includePackageNameRow) {
      children.add(
        _groupLessonScheduleStyleInfoRow(
          theme,
          icon: Icons.library_music_outlined,
          label: labels.trainerServicePlanRosterPackageLabel,
          value: name,
          valueMaxLines: 1,
        ),
      );
    }

    if (dateValue.isNotEmpty) {
      if (children.isNotEmpty) children.add(gap);
      children.add(
        _groupLessonScheduleStyleInfoRow(
          theme,
          icon: Icons.date_range_outlined,
          label: labels.trainerServicePlanRosterPackagePeriodLabel,
          value: dateValue,
          valueMaxLines: 1,
        ),
      );
    }

    if (children.isNotEmpty) children.add(gap);
    children.add(
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _groupLessonScheduleStyleInfoRow(
              theme,
              icon: Icons.confirmation_number_outlined,
              label: labels.remaining,
              value: remStr,
              valueMaxLines: 1,
            ),
          ),
          Expanded(
            child: _groupLessonScheduleStyleInfoRow(
              theme,
              icon: Icons.flag_outlined,
              label: labels.trainerServicePlanRosterPackageStatusLabel,
              value: statusText,
              valueMaxLines: 1,
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  /// Açılır menü öğesi — tam grid yerine özet satırlar.
  Widget _buildDropdownMenuPackageSummary(
    BaseTheme theme,
    AppLabels labels,
    TrainerEnrollmentPackageOptionModel o,
    Color ink900,
  ) {
    final name = o.name.trim().isEmpty ? '—' : o.name.trim();
    final rem = o.remainingQty;
    final sd = DateFormatUtils.formatDayMonthYearDots(o.startDate);
    final ed = DateFormatUtils.formatDayMonthYearDots(o.endDate);
    final dateLine = (sd.isNotEmpty && ed.isNotEmpty)
        ? '$sd - $ed'
        : (sd.isNotEmpty ? sd : (ed.isNotEmpty ? ed : ''));
    final muted = theme.defaultGray500Color;
    final isActive =
        TrainerPackageOptionSituation.allowsAttendanceActions(o.situation);
    final statusStr =
        '${labels.trainerServicePlanRosterPackageStatusLabel}: ${isActive ? labels.activeStatus : labels.passiveStatus}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textSmall(color: ink900),
        ),
        if (rem != null) ...[
          SizedBox(height: theme.panelTightVerticalGap * 2),
          Text(
            '${labels.remaining}: $rem',
            style: theme.textCaption(color: muted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (dateLine.isNotEmpty) ...[
          SizedBox(height: theme.panelTightVerticalGap * 2),
          Text(
            dateLine,
            style: theme.textCaption(color: muted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        SizedBox(height: theme.panelTightVerticalGap * 2),
        Text(
          statusStr,
          style: theme.textCaption(color: muted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Future<void> _loadPackageOptionsIfNeeded(TrainerCalendarEnrollmentRowModel en) async {
    if (_packageOptionsByEnrollmentId.containsKey(en.id)) {
      return;
    }
    if (_packageOptionFetchStartedIds.contains(en.id)) {
      return;
    }

    final evt = _event;
    if (evt == null || evt.servicePlanId <= 0 || en.memberRegisterId == null) {
      return;
    }

    if (!mounted) return;

    _packageOptionFetchStartedIds.add(en.id);
    setState(() => _packageOptionsLoading.add(en.id));

    /// Başarısızlıkta da map’e yazılır; aksi halde her [build] tekrar istek döngüsü oluşur.
    TrainerEnrollmentPackageOptionsOutputModel result =
        const TrainerEnrollmentPackageOptionsOutputModel();

    try {
      final external = context.read<ExternalApplicationsConfigCubit>().state;
      final token = await JwtStorageService.getToken();

      if (mounted &&
          external != null &&
          token != null &&
          token.isNotEmpty) {
        final data = await TrainerEnrollmentPackageService.fetchPackageOptions(
          baseUrl: external.onlineReservation,
          token: token,
          planId: evt.servicePlanId,
          enrollmentId: en.id,
        );
        result = data ?? const TrainerEnrollmentPackageOptionsOutputModel();
      }
    } catch (_) {
      result = const TrainerEnrollmentPackageOptionsOutputModel();
    } finally {
      _packageOptionFetchStartedIds.remove(en.id);
      if (mounted) {
        setState(() {
          _packageOptionsByEnrollmentId[en.id] = result;
          _packageOptionsLoading.remove(en.id);
        });
      }
    }
  }

  Widget _buildEnrollmentPackageBlock(
    BaseTheme theme,
    AppLabels labels,
    TrainerCalendarEnrollmentRowModel en,
    Color ink900,
  ) {
    if (en.memberRegisterId == null) {
      return _buildPackageUnavailableHint(theme, labels);
    }

    if (!_packageOptionsByEnrollmentId.containsKey(en.id) &&
        !_packageOptionsLoading.contains(en.id)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadPackageOptionsIfNeeded(en);
        }
      });
    }

    if (_packageOptionsLoading.contains(en.id)) {
      return Padding(
        padding: EdgeInsets.only(top: theme.panelTightVerticalGap * 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: _packageInlineLoaderSize,
              width: _packageInlineLoaderSize,
              child: CircularProgressIndicator(
                strokeWidth: _packageInlineLoaderStrokeWidth,
                color: theme.default500Color,
              ),
            ),
            SizedBox(width: theme.panelTightVerticalGap),
            Expanded(
              child: Text(
                labels.loading,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textSmall(color: theme.defaultGray500Color),
              ),
            ),
          ],
        ),
      );
    }

    final data = _packageOptionsByEnrollmentId[en.id];
    final opts = data?.options ?? [];
    if (opts.isEmpty) {
      return _buildPackageUnavailableHint(theme, labels);
    }

    final effectiveId = _effectiveMemberRegisterId(en)!;
    TrainerEnrollmentPackageOptionModel selectedOpt = opts.first;
    for (final o in opts) {
      if (o.memberRegisterId == effectiveId) {
        selectedOpt = o;
        break;
      }
    }

    final dropdownValue = opts.any((o) => o.memberRegisterId == effectiveId)
        ? effectiveId
        : opts.first.memberRegisterId;

    final hints = <Widget>[];
    final act = TrainerPackageOptionSituation.allowsAttendanceActions(
      selectedOpt.situation,
    );
    final remainingExhausted =
        selectedOpt.remainingQty != null && selectedOpt.remainingQty! <= 0;
    if (remainingExhausted) {
      hints.add(
        _buildPackageHintLine(theme, labels.trainerServicePlanRosterPackageNoRemainingHint),
      );
    } else if (!act) {
      hints.add(
        _buildPackageHintLine(theme, labels.trainerServicePlanRosterPackagePassiveHint),
      );
    }
    if (_pendingMemberRegisterByEnrollmentId.containsKey(en.id)) {
      hints.add(
        _buildPackageHintLine(theme, labels.trainerServicePlanRosterPackagePendingApplyHint),
      );
    }

    final panelInner = opts.length <= 1
        ? _buildPackageDetailsColumn(
            theme,
            labels,
            selectedOpt,
            includePackageNameRow: true,
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<int>(
                isExpanded: true,
                value: dropdownValue,
                style: theme.textBodyBold(color: ink900),
                underline: SizedBox(height: theme.panelDividerThickness),
                selectedItemBuilder: (context) {
                  return [
                    for (final o in opts)
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          o.name.trim().isEmpty ? '—' : o.name.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textBodyBold(color: ink900),
                        ),
                      ),
                  ];
                },
                items: [
                  for (final o in opts)
                    DropdownMenuItem<int>(
                      value: o.memberRegisterId,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: theme.panelTightVerticalGap * 2,
                        ),
                        child: _buildDropdownMenuPackageSummary(
                          theme,
                          labels,
                          o,
                          ink900,
                        ),
                      ),
                    ),
                ],
                onChanged: _saving
                    ? null
                    : (v) {
                        if (v == null) return;
                        setState(() {
                          if (v == en.memberRegisterId) {
                            _pendingMemberRegisterByEnrollmentId.remove(en.id);
                          } else {
                            _pendingMemberRegisterByEnrollmentId[en.id] = v;
                          }
                        });
                      },
              ),
              SizedBox(height: theme.panelCompactInset + 2),
              _buildPackageDetailsColumn(
                theme,
                labels,
                selectedOpt,
                includePackageNameRow: false,
              ),
            ],
          );

    return Padding(
      padding: EdgeInsets.only(top: theme.panelTightVerticalGap * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _lessonScheduleCardStyleInfoPanel(theme, panelInner),
          ...hints,
        ],
      ),
    );
  }

  Future<void> _save() async {
    var e = _event;
    if (e == null || e.servicePlanId <= 0 || _saving) return;

    final external = context.read<ExternalApplicationsConfigCubit>().state;
    if (external == null) return;
    final base = external.onlineReservation;
    final token = await JwtStorageService.getToken();
    if (token == null || token.isEmpty) return;

    setState(() => _saving = true);
    try {
      final pendingSnapshot =
          Map<int, int>.from(_pendingMemberRegisterByEnrollmentId);
      if (pendingSnapshot.isNotEmpty) {
        var didPatch = false;
        for (final entry in pendingSnapshot.entries) {
          final enrollmentId = entry.key;
          final newRegisterId = entry.value;
          TrainerCalendarEnrollmentRowModel? enRow;
          for (final x in _visibleEnrollmentsForEvent(e)) {
            if (x.id == enrollmentId) {
              enRow = x;
              break;
            }
          }
          if (enRow == null) continue;
          if (enRow.memberRegisterId == newRegisterId) continue;

          didPatch = true;
          final ok =
              await TrainerEnrollmentPackageService.updateEnrollmentPackage(
            baseUrl: base,
            token: token,
            planId: e.servicePlanId,
            enrollmentId: enrollmentId,
            memberRegisterId: newRegisterId,
          );
          if (!mounted) return;
          if (!ok) {
            await warningDialog(
              context,
              message:
                  AppLabels.current.trainerServicePlanRosterPackageUpdateFailed,
              path: BlocTheme.theme.attentionSvgPath,
            );
            await _load(showFullScreenLoading: false);
            if (mounted) {
              setState(() {
                _pendingMemberRegisterByEnrollmentId.clear();
              });
            }
            return;
          }
        }

        if (mounted) {
          setState(() {
            _pendingMemberRegisterByEnrollmentId.clear();
            if (didPatch) {
              _packageOptionsByEnrollmentId.clear();
              _packageOptionFetchStartedIds.clear();
            }
          });
        }

        if (didPatch) {
          await _load(showFullScreenLoading: false);
          if (!mounted) return;
          e = _event;
          if (e == null) return;
        }
      }

    final dateStr = _lessonDateYmd(e);
    final trackPayment = e.trackPayment;
    final planId = e.servicePlanId;
    final enrollments = _visibleEnrollmentsForEvent(e);
    final reservations = e.reservations;

    final serverBurnedIds = <int>{
      for (final r in reservations)
        if (r.userId != null && _isBurned(r.attendance)) r.userId!,
    };

    final presentIds = _presentByUserId.entries
        .where((x) => x.value && !_pendingBurns.contains(x.key))
        .map((x) => x.key)
        .where(_packageActionsAllowedForUserId)
        .toList();

    final absentIds = _presentByUserId.entries
        .where((x) => !x.value && !_pendingBurns.contains(x.key))
        .map((x) => x.key)
        .toList();

    final absentNonBurnedIds = absentIds
        .where(
          (id) => !serverBurnedIds.contains(id) || _pendingUnburns.contains(id),
        )
        .where(_packageActionsAllowedForUserId)
        .toList();

    final unburns =
        _pendingUnburns.where(_packageActionsAllowedForUserId).toList();

      if (unburns.isNotEmpty) {
        final res = await TrainerServicePlanBulkAttendanceService.deleteUnburn(
          randevuApiBaseUrl: base,
          token: token,
          servicePlanId: planId,
          dateYmd: dateStr,
          trackPayment: trackPayment,
          userIds: unburns,
        );
        if (!mounted) return;
        if (!res.isSuccess) {
          await warningDialog(
            context,
            message: AppLabels.current.trainerServicePlanRosterSaveFailed,
            path: BlocTheme.theme.attentionSvgPath,
          );
          return;
        }
      }

      final attendanceFutures = <Future<dynamic>>[];

      if (presentIds.isNotEmpty) {
        final students = <Map<String, dynamic>>[];
        for (final userId in presentIds) {
          TrainerCalendarEnrollmentRowModel? enr;
          for (final x in enrollments) {
            if (x.userId == userId) {
              enr = x;
              break;
            }
          }
          students.add(<String, dynamic>{
            'user_id': userId,
            'member_register_id': enr?.memberRegisterId,
          });
        }
        attendanceFutures.add(
          TrainerServicePlanBulkAttendanceService.postAttendanceBulk(
            randevuApiBaseUrl: base,
            token: token,
            servicePlanId: planId,
            dateYmd: dateStr,
            trackPayment: trackPayment,
            students: students,
          ),
        );
      }

      if (absentNonBurnedIds.isNotEmpty) {
        attendanceFutures.add(
          TrainerServicePlanBulkAttendanceService.deleteAttendanceBulk(
            randevuApiBaseUrl: base,
            token: token,
            servicePlanId: planId,
            dateYmd: dateStr,
            trackPayment: trackPayment,
            userIds: absentNonBurnedIds,
          ),
        );
      }

      if (attendanceFutures.isNotEmpty) {
        final results = await Future.wait(attendanceFutures);
        for (final r in results) {
          if (r is! ApiResponse || !r.isSuccess) {
            if (!mounted) return;
            await warningDialog(
              context,
              message: AppLabels.current.trainerServicePlanRosterSaveFailed,
              path: BlocTheme.theme.attentionSvgPath,
            );
            return;
          }
        }
      }

      final burns = _pendingBurns
          .where(_packageActionsAllowedForUserId)
          .toList()
        ..sort();
      for (final userId in burns) {
        TrainerCalendarEnrollmentRowModel? enr;
        for (final x in enrollments) {
          if (x.userId == userId) {
            enr = x;
            break;
          }
        }
        final res = await TrainerServicePlanBulkAttendanceService.postBurn(
          randevuApiBaseUrl: base,
          token: token,
          servicePlanId: planId,
          dateYmd: dateStr,
          trackPayment: trackPayment,
          userIds: <int>[userId],
          memberRegisterId: enr?.memberRegisterId,
        );
        if (!mounted) return;
        if (!res.isSuccess) {
          await warningDialog(
            context,
            message: AppLabels.current.trainerServicePlanRosterSaveFailed,
            path: BlocTheme.theme.attentionSvgPath,
          );
          return;
        }
      }

      await _load(showFullScreenLoading: false);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _pillBadge(
    BaseTheme theme,
    String text,
    Color contentColor, {
    /// Yoklama Evet/Hayır rozeti ile aynı punto (`textMini`).
    bool useMiniText = false,
  }) {
    return Container(
      padding: TrainerGroupLessonScheduleCardStyle.headerPillPadding,
      decoration:
          TrainerGroupLessonScheduleCardStyle.headerPillDecoration(contentColor),
      child: Text(
        text,
        style: useMiniText
            ? theme.textMini(color: contentColor)
            : theme.textSmall(color: contentColor),
      ),
    );
  }

  /// Yoklama Evet/Hayır — üye paneli ödeme planı durum rozeti ile aynı mantık (tek renk).
  /// Evet → success, Hayır → warning (paket uygunluğundan bağımsız).
  Widget _presentAttendancePillBadge({
    required BaseTheme theme,
    required AppLabels labels,
    required bool present,
  }) {
    final accentColor =
        present ? theme.panelSuccessColor : theme.panelWarningColor;
    final line =
        '${labels.trainerServicePlanRosterPresentLabel}: ${present ? labels.yes : labels.no}';
    return Padding(
      padding: EdgeInsets.only(top: theme.panelHomeBlockGap),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color:
                accentColor.withValues(alpha: _presentAttendanceBadgeBgOpacity),
            borderRadius:
                BorderRadius.circular(_presentAttendanceBadgeRadius),
          ),
          child: Text(
            line,
            style: theme.textMini(color: accentColor),
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _studentRowHizliRandevuStyle(
    BaseTheme theme,
    AppLabels labels,
    TrainerCalendarEnrollmentRowModel en, {
    required bool isFirst,
  }) {
    final uid = en.userId;
    if (uid == null) return const SizedBox.shrink();

    final name = en.memberName.trim().isEmpty ? labels.summaryValueNone : en.memberName;
    final phase = _burnUiPhase(uid);
    final present = _presentByUserId[uid] ?? false;
    final ink900 = theme.default900Color;
    final packageActionsOk = _canOperatePackageActions(en);

    late final Widget bottomLeading;
    late final Widget bottomTrailing;
    switch (phase) {
      case TrainerRosterBurnUiPhase.burned:
        bottomLeading = Align(
          alignment: AlignmentDirectional.centerStart,
          child: _pillBadge(
            theme,
            labels.burned,
            theme.panelDangerColor,
          ),
        );
        bottomTrailing = IconButton(
          constraints: const BoxConstraints(
            minWidth: _iconHitMinSide,
            minHeight: _iconHitMinSide,
          ),
          padding: EdgeInsets.zero,
          tooltip: labels.logActionLabels['unburn'] ?? '',
          onPressed: packageActionsOk
              ? () {
                  setState(() {
                    if (_pendingUnburns.contains(uid)) {
                      _pendingUnburns.remove(uid);
                    } else {
                      _pendingUnburns.add(uid);
                    }
                  });
                }
              : null,
          icon: Icon(
            Icons.whatshot_outlined,
            color: packageActionsOk
                ? theme.panelWarningColor
                : theme.defaultGray400Color,
            size: theme.panelRowIconSize,
          ),
        );
        break;
      case TrainerRosterBurnUiPhase.pendingUnburn:
        bottomLeading = Align(
          alignment: AlignmentDirectional.centerStart,
          child: _pillBadge(
            theme,
            labels.trainerServicePlanRosterWillUnburn,
            theme.panelWarningColor,
          ),
        );
        bottomTrailing = IconButton(
          constraints: const BoxConstraints(
            minWidth: _iconHitMinSide,
            minHeight: _iconHitMinSide,
          ),
          padding: EdgeInsets.zero,
          onPressed: packageActionsOk
              ? () => setState(() => _pendingUnburns.remove(uid))
              : null,
          icon: Icon(
            Icons.undo,
            color: packageActionsOk ? ink900 : theme.defaultGray400Color,
            size: theme.panelRowIconSize,
          ),
        );
        break;
      case TrainerRosterBurnUiPhase.pendingBurn:
        bottomLeading = Align(
          alignment: AlignmentDirectional.centerStart,
          child: _pillBadge(
            theme,
            labels.trainerServicePlanRosterWillBurn,
            theme.panelDangerColor,
            useMiniText: true,
          ),
        );
        bottomTrailing = IconButton(
          constraints: const BoxConstraints(
            minWidth: _iconHitMinSide,
            minHeight: _iconHitMinSide,
          ),
          padding: EdgeInsets.zero,
          onPressed: packageActionsOk
              ? () => setState(() => _pendingBurns.remove(uid))
              : null,
          icon: Icon(
            Icons.undo,
            color: packageActionsOk ? ink900 : theme.defaultGray400Color,
            size: theme.panelRowIconSize,
          ),
        );
        break;
      case TrainerRosterBurnUiPhase.normal:
        bottomLeading = Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_canMarkBurn(uid))
              IconButton(
                constraints: const BoxConstraints(
                  minWidth: _iconHitMinSide,
                  minHeight: _iconHitMinSide,
                ),
                padding: EdgeInsets.zero,
                tooltip: labels.logActionLabels['burn'] ?? labels.burnRight,
                onPressed: () => setState(() => _pendingBurns.add(uid)),
                icon: Icon(
                  Icons.local_fire_department_outlined,
                  color: theme.panelDangerColor,
                  size: theme.panelRowIconSize,
                ),
              ),
          ],
        );
        bottomTrailing = Switch(
          value: present,
          onChanged: (!packageActionsOk || _pendingBurns.contains(uid))
              ? null
              : (v) => setState(() => _presentByUserId[uid] = v),
          activeTrackColor: theme.default500Color.withValues(alpha: 0.45),
          activeThumbColor: theme.default500Color,
          inactiveThumbColor: theme.defaultGray400Color,
          inactiveTrackColor: theme.defaultGray200Color.withValues(alpha: 0.85),
          trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return theme.defaultGray300Color;
            }
            if (states.contains(WidgetState.selected)) {
              return null;
            }
            return theme.defaultGray300Color;
          }),
        );
        break;
    }

    return Container(
      decoration: _hizliRandevuListItemDecoration(theme),
      margin: EdgeInsets.only(
        top: isFirst ? 0 : theme.panelHomeBlockGap,
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          theme.panelCardInnerPadding.left,
          theme.panelCompactInset + 2,
          theme.panelCompactInset,
          theme.panelCompactInset + 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: _studentHeaderAvatarRadius,
                  backgroundColor:
                      theme.default900Color.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.person,
                    color: theme.default900Color,
                    size: theme.panelRowIconSize,
                  ),
                ),
                SizedBox(width: theme.panelInlineLeadingGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: theme.textBodyBold(color: ink900),
                      ),
                      Text(
                        labels.member,
                        style: theme.textMini(
                          color:
                              theme.default900Color.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _buildEnrollmentPackageBlock(theme, labels, en, ink900),
            if (phase == TrainerRosterBurnUiPhase.normal)
              _presentAttendancePillBadge(
                theme: theme,
                labels: labels,
                present: present,
              ),
            SizedBox(height: theme.panelHomeBlockGap),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: bottomLeading,
                  ),
                ),
                bottomTrailing,
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Liste altı; Kaydet gövdede scroll ile geldiği için yalnızca alt nav için rezerv.
  double _listViewBottomInset(BaseTheme theme) {
    return _listBottomPadding + _bottomTabBarReserve;
  }

  Widget _buildSaveButton(BaseTheme theme, AppLabels labels) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _saving ? null : _save,
        icon: _saving
            ? SizedBox(
                width: _saveSpinnerSize,
                height: _saveSpinnerSize,
                child: CircularProgressIndicator(
                  strokeWidth: theme.panelDividerThickness * 2,
                  color: theme.defaultBlackColor,
                ),
              )
            : Icon(
                Icons.save_outlined,
                color: theme.defaultBlackColor,
              ),
        label: Text(labels.save),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.default500Color,
          foregroundColor: theme.defaultBlackColor,
          textStyle: theme.panelButtonTextStyle,
          disabledBackgroundColor: theme.defaultGray400Color,
          disabledForegroundColor: theme.defaultGray600Color,
          padding: EdgeInsets.symmetric(
            vertical: theme.panelInlineLeadingGap,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(theme.panelButtonRadius),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BaseTheme theme,
    AppLabels labels,
    TrainerScheduleCalendarEventModel e,
  ) {
    final edge = theme.panelPagePadding.left;
    final enrollments = _visibleEnrollmentsForEvent(e);
    final listBottom = _listViewBottomInset(theme);

    final children = <Widget>[
      TrainerGroupLessonScheduleCard(
        data: e,
        theme: theme,
        labels: labels,
        outerMargin: EdgeInsets.zero,
        onCapacityBadgeTap: () =>
            TrainerLessonScheduleParticipantsDialog.show(context, e),
      ),
      SizedBox(height: theme.panelSectionSpacing),
      // [FitnessPrograme] program adı satırı gibi düz başlık (kutu/gölge yok).
      Padding(
        padding: EdgeInsetsDirectional.only(
          end: theme.panelCompactInset,
          bottom: theme.panelCompactInset,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                labels.members,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textSubtitle(color: theme.defaultBlackColor),
              ),
            ),
          ],
        ),
      ),
    ];

    if (enrollments.isEmpty) {
      children.add(
        SizedBox(
          height: _emptyStateMinHeight,
          child: Center(
            child: NoDataTextWidget(
              text: labels.trainerServicePlanRosterNoEnrolled,
            ),
          ),
        ),
      );
    } else {
      for (var i = 0; i < enrollments.length; i++) {
        children.add(
          _studentRowHizliRandevuStyle(
            theme,
            labels,
            enrollments[i],
            isFirst: i == 0,
          ),
        );
      }
      children.add(SizedBox(height: _saveBelowLastCardGap));
      children.add(_buildSaveButton(theme, labels));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          left: edge,
          right: edge,
          top: theme.panelHomeBlockGap,
          bottom: listBottom,
        ),
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;
    final e = _event;

    return Scaffold(
      appBar: TopAppBarWidget(
        title: labels.trainerServicePlanRosterTitle,
      ),
      backgroundColor: theme.defaultBackgroundColor,
      bottomNavigationBar: BottomNavigationBarWidget(
        tab: NavTab.home,
      ),
      body: _loading || e == null
          ? const Center(child: LoadingIndicatorWidget())
          : _buildBody(theme, labels, e),
    );
  }
}
