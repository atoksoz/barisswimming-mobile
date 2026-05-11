import 'dart:convert';

import 'package:e_sport_life/config/ability/mobile_ability_cubit.dart';
import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/constants/mobile_ability_subjects.dart';
import 'package:e_sport_life/core/constants/url/randevu_al_url_constants.dart';
import 'package:e_sport_life/core/constants/url/security_code_url_constants.dart';
import 'package:e_sport_life/core/enums/supported_locale.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/utils/date_format_utils.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/image_popup_widget.dart';
import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:e_sport_life/core/widgets/confirm_dialog_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/core/widgets/trainer_group_lesson_schedule_card.dart';
import 'package:e_sport_life/core/widgets/warning_dialog_widget.dart';
import 'package:e_sport_life/data/model/common/trainer_schedule_calendar_event_model.dart';
import 'package:e_sport_life/screen/panel/common/attendance/attendance_lesson_pick_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

enum _ScreenState { landing, scanning, memberView }

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({
    super.key,
    this.openScannerOnLaunch = false,
    this.presetAttendanceLesson,
  });

  /// [true] ise ekran açılır açılmaz QR tarama görünür (hızlı erişim).
  final bool openScannerOnLaunch;

  /// Ders programından gelince ders seçim adımı atlanır; gün/saat/konum üstte gösterilir.
  final TrainerScheduleCalendarEventModel? presetAttendanceLesson;

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  _ScreenState _screenState = _ScreenState.landing;
  MobileScannerController? _scannerController;
  bool _isLoading = false;
  bool _processingQr = false;

  Map<String, dynamic>? _memberData;
  List<dynamic> _memberPackages = [];
  List<dynamic> _deductionHistory = [];
  int _memberTabIndex = 0; // 0: Aktif Paketler, 1: Paket Düşümleri
  int _historyCurrentPage = 1;
  int _historyLastPage = 1;
  bool _isLoadingMore = false;

  final TextEditingController _cardController = TextEditingController();
  final FocusNode _cardFocusNode = FocusNode();
  final ScrollController _historyScrollController = ScrollController();

  /// Önceden seçilen ders: kapalıyken yalnız üst satır (devamını görüntüle).
  bool _presetLessonDetailExpanded = false;

  @override
  void initState() {
    super.initState();
    _historyScrollController.addListener(_onHistoryScroll);
    if (widget.openScannerOnLaunch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _openScanner();
      });
    }
  }

  @override
  void didUpdateWidget(AttendanceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldPid = oldWidget.presetAttendanceLesson?.servicePlanId;
    final newPid = widget.presetAttendanceLesson?.servicePlanId;
    if (oldPid != newPid) {
      _presetLessonDetailExpanded = false;
    }
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    _cardController.dispose();
    _cardFocusNode.dispose();
    _historyScrollController.dispose();
    super.dispose();
  }

  void _onHistoryScroll() {
    if (_historyScrollController.position.pixels >=
            _historyScrollController.position.maxScrollExtent - 100 &&
        !_isLoadingMore &&
        _historyCurrentPage < _historyLastPage) {
      _loadMoreHistory();
    }
  }

  // ─── Navigation Helpers ───

  void _openScanner() {
    _scannerController?.dispose();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
    setState(() {
      _screenState = _ScreenState.scanning;
      _processingQr = false;
      _isLoading = false;
    });
  }

  void _backToLanding() {
    _scannerController?.stop();
    _cardController.clear();
    setState(() {
      _screenState = _ScreenState.landing;
      _memberData = null;
      _memberPackages = [];
      _deductionHistory = [];
      _memberTabIndex = 0;
      _historyCurrentPage = 1;
      _historyLastPage = 1;
      _isLoading = false;
      _processingQr = false;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _cardFocusNode.requestFocus();
    });
  }

  void _resetToScanner() {
    _cardController.clear();
    _memberData = null;
    _memberPackages = [];
    _deductionHistory = [];
    _memberTabIndex = 0;
    _historyCurrentPage = 1;
    _historyLastPage = 1;
    _openScanner();
  }

  void _debugLogAttendanceResponse(String label, ApiResponse result) {
    final body = result.body;
    if (body is Map<String, dynamic>) {
      debugPrint(
        '[Attendance] $label → status=${result.statusCode} '
        'isSuccess=${result.isSuccess} body=${jsonEncode(body)}',
      );
    } else {
      debugPrint(
        '[Attendance] $label → status=${result.statusCode} '
        'isSuccess=${result.isSuccess} body=$body',
      );
    }
  }

  /// Aktif paket GET bazen boş veya [output] liste değil (proxy farkı); üye detayındaki
  /// [packages] ile yedeklenir — yapı randevu `member-detail` ile uyumludur.
  List<dynamic> _resolveAttendancePackageList(
    ApiResponse packagesResponse,
    Map<String, dynamic>? memberOutputMap,
  ) {
    final direct = packagesResponse.outputList;
    if (direct != null && direct.isNotEmpty) {
      return direct;
    }

    final rawOut = packagesResponse.output;
    if (rawOut is Map) {
      final nested = rawOut['packages'];
      if (nested is List && nested.isNotEmpty) {
        return List<dynamic>.from(nested);
      }
    }

    final fromDetail = memberOutputMap?['packages'];
    if (fromDetail is List<dynamic>) {
      final activeOnly = fromDetail.where((p) {
        if (p is! Map) return false;
        return p['situation']?.toString() == 'active';
      }).toList();
      if (activeOnly.isNotEmpty) {
        return activeOnly;
      }
      if (fromDetail.isNotEmpty) {
        return List<dynamic>.from(fromDetail);
      }
    }

    return [];
  }

  // ─── Card Number Search ───

  Future<void> _searchByCardNumber() async {
    final labels = AppLabels.current;
    final cardNumber = _cardController.text.trim();

    if (cardNumber.isEmpty) {
      _showError(labels.cardNumberInvalid);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      if (externalConfig == null) {
        _showError(labels.error);
        setState(() => _isLoading = false);
        return;
      }

      final url = RandevuAlUrlConstants.getAttendanceMemberByCardUrl(
          externalConfig.onlineReservation, cardNumber);
      final result = await RequestUtil.getJson(url);

      _debugLogAttendanceResponse('member-by-card', result);

      final memberId = result.outputMap?['id'] ?? result.outputMap?['member_id'];
      if (memberId == null) {
        _showError(
          result.randevuUserMessage ?? labels.memberNotFoundByCard,
        );
        setState(() => _isLoading = false);
        return;
      }

      await _fetchMemberAndPackages(int.parse(memberId.toString()));
    } catch (e) {
      debugPrint('Card search error: $e');
      _showError(labels.memberNotFoundByCard);
      setState(() => _isLoading = false);
    }
  }

  // ─── QR Parse & Validation ───

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_isLoading || _processingQr) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    _processingQr = true;
    _scannerController?.stop();
    _validateQrAndFetchMember(barcode.rawValue!);
  }

  /// security-code format: time(10) + password(4) + user_id(remaining)
  Map<String, String>? _parseSecurityCode(String raw) {
    if (raw.length < 15) return null;
    final password = raw.substring(10, 14);
    final userId = raw.substring(14);
    if (int.tryParse(password) == null || int.tryParse(userId) == null) {
      return null;
    }
    return {'password': password, 'userId': userId};
  }

  Future<void> _validateQrAndFetchMember(String qrValue) async {
    final labels = AppLabels.current;

    final parsed = _parseSecurityCode(qrValue);
    if (parsed == null) {
      _showError(labels.invalidOrExpiredQr);
      _resetToScanner();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      if (externalConfig == null) {
        _showError(labels.error);
        _resetToScanner();
        return;
      }

      final validationUrl = SecurityCodeUrlConstants.getUseSecurityCodeUrl(
        externalConfig.securityCode,
        externalConfig.applicationId.toString(),
        parsed['password']!,
        parsed['userId']!,
      );
      final validationResult = await RequestUtil.getJson(validationUrl);

      if (!validationResult.isSuccess ||
          validationResult.output == null ||
          validationResult.output == false) {
        _showError(labels.invalidOrExpiredQr);
        _resetToScanner();
        return;
      }

      final memberId = int.tryParse(parsed['userId']!);
      if (memberId == null) {
        _showError(labels.invalidOrExpiredQr);
        _resetToScanner();
        return;
      }

      await _fetchMemberAndPackages(memberId);
    } catch (e) {
      debugPrint('QR validation error: $e');
      _showError(labels.invalidOrExpiredQr);
      _resetToScanner();
    }
  }

  // ─── Member & Package Fetch ───

  Future<void> _fetchMemberAndPackages(int memberId) async {
    final labels = AppLabels.current;

    try {
      final externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      if (externalConfig == null) {
        _showError(labels.error);
        _resetToScanner();
        return;
      }

      final memberUrl = RandevuAlUrlConstants.getAttendanceMemberDetailUrl(
          externalConfig.onlineReservation, memberId);
      final memberResult = await RequestUtil.getJson(memberUrl);

      _debugLogAttendanceResponse('member-detail', memberResult);

      if (!memberResult.isSuccess || memberResult.output == null) {
        final errorExtras = (memberResult.body is Map) ? memberResult.body['extras']?.toString() : null;
        _showError(errorExtras?.isNotEmpty == true ? errorExtras! : labels.noData);
        _resetToScanner();
        return;
      }

      final packagesUrl =
          RandevuAlUrlConstants.getAttendanceMemberPackagesUrl(
              externalConfig.onlineReservation, memberId);
      final historyUrl =
          '${RandevuAlUrlConstants.getAttendanceMemberHistoryUrl(externalConfig.onlineReservation, memberId)}?page=1&per_page=15';

      final results = await Future.wait([
        RequestUtil.getJson(packagesUrl),
        RequestUtil.getJson(historyUrl),
      ]);

      _debugLogAttendanceResponse('member-active-packages', results[0]);
      _debugLogAttendanceResponse('member-attendance-history', results[1]);

      final historyOutput = results[1].outputMap ?? {};

      if (mounted) {
        final memberOut = memberResult.outputMap ?? {'id': memberId};
        setState(() {
          _memberData = memberOut;
          _memberPackages = _resolveAttendancePackageList(
            results[0],
            memberOut,
          );
          _deductionHistory = List<dynamic>.from(historyOutput['data'] ?? []);
          _historyCurrentPage = historyOutput['current_page'] ?? 1;
          _historyLastPage = historyOutput['last_page'] ?? 1;
          _isLoading = false;
          _processingQr = false;
          _screenState = _ScreenState.memberView;
        });
      }
    } catch (e) {
      debugPrint('Member fetch error: $e');
      _showError(labels.error);
      _resetToScanner();
    }
  }

  void _switchTab(int index) {
    if (_memberTabIndex == index) return;
    setState(() => _memberTabIndex = index);
    final memberId = _memberData?['id'] ?? _memberData?['member_id'];
    if (memberId != null) {
      _fetchMemberAndPackages(int.parse(memberId.toString()));
    }
  }

  Future<void> _loadMoreHistory() async {
    if (_isLoadingMore || _historyCurrentPage >= _historyLastPage) return;

    final memberId = _memberData?['id'] ?? _memberData?['member_id'];
    if (memberId == null) return;

    setState(() => _isLoadingMore = true);

    try {
      final externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      if (externalConfig == null) return;

      final nextPage = _historyCurrentPage + 1;
      final url =
          '${RandevuAlUrlConstants.getAttendanceMemberHistoryUrl(externalConfig.onlineReservation, int.parse(memberId.toString()))}?page=$nextPage&per_page=15';

      final result = await RequestUtil.getJson(url);
      final output = result.outputMap ?? {};

      if (mounted) {
        setState(() {
          _deductionHistory.addAll(List<dynamic>.from(output['data'] ?? []));
          _historyCurrentPage = output['current_page'] ?? nextPage;
          _historyLastPage = output['last_page'] ?? _historyLastPage;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      debugPrint('Load more history error: $e');
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  // ─── Take Attendance (Hak Düşümü) ───

  Future<void> _takeAttendance(Map<String, dynamic> package) async {
    final labels = AppLabels.current;
    final productName = package['name'] ?? package['product_name'] ?? '';

    try {
      TrainerScheduleCalendarEventModel? selected =
          widget.presetAttendanceLesson;
      if (selected == null || selected.servicePlanId <= 0) {
        selected = await pushLessonPickForAttendance(context);
      }
      if (!mounted || selected == null) return;
      if (selected.servicePlanId <= 0) {
        _showError(labels.error);
        return;
      }

      final lessonCtx = _lessonContextLines(selected, labels);
      final confirmed = await confirmDialog(
        context,
        message: '$productName\n\n$lessonCtx\n\n${labels.burnConfirm}',
      );

      if (confirmed != true) return;
      if (!mounted) return;

      setState(() => _isLoading = true);

      final externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      if (externalConfig == null) return;

      final memberRegisterId =
          package['member_register_id'] ?? package['id'];
      if (memberRegisterId == null) {
        _showError(labels.burnError);
        return;
      }

      final memberId = _memberData!['id'] ?? _memberData!['member_id'];
      final memberName =
          _memberData!['name'] ?? _memberData!['full_name'] ?? '';
      final memberPhone = _memberData!['phone'] ?? '';

      final url = RandevuAlUrlConstants.getAttendanceTakeUrl(
          externalConfig.onlineReservation);

      final result = await RequestUtil.postJson(url, body: {
        'member_id': int.parse(memberId.toString()),
        'member_register_id': int.parse(memberRegisterId.toString()),
        'member_name': memberName,
        'member_phone': memberPhone,
        'product_name': productName,
        'service_plan_id': selected.servicePlanId,
      });

      if (mounted) {
        if (result.isSuccess) {
          setState(() => _isLoading = false);
          await warningDialog(context, message: labels.burnSuccess);
          if (mounted) {
            setState(() => _isLoading = true);
            await _fetchMemberAndPackages(int.parse(memberId.toString()));
          }
        } else {
          final errorMessage =
              (result.body is Map && result.body['extras'] != null && result.body['extras'].toString().isNotEmpty)
                  ? result.body['extras'].toString()
                  : labels.burnError;
          _showError(errorMessage);
        }
      }
    } catch (e) {
      debugPrint('Attendance error: $e');
      _showError(AppLabels.current.burnError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Undo Deduction (Paket Düşümü Geri Al) ───

  Future<void> _undoDeduction(Map<String, dynamic> record) async {
    final labels = AppLabels.current;
    final note = record['note'] ?? '';

    final confirmed = await confirmDialog(
      context,
      message: '${note.toString().isNotEmpty ? '$note\n\n' : ''}${labels.undoDeductionConfirm}',
      confirmButtonText: labels.undoDeduction,
    );

    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      if (externalConfig == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final id = record['id'];
      final url = RandevuAlUrlConstants.getAttendanceUndoUrl(
          externalConfig.onlineReservation, id);

      final result = await RequestUtil.deleteJson(url);
      final payloadStatus = (result.body is Map) ? int.tryParse(result.body['status'].toString()) : null;
      final isPayloadSuccess = result.isSuccess && (payloadStatus == null || payloadStatus < 400);

      if (mounted) {
        if (isPayloadSuccess) {
          final memberId = _memberData?['id'] ?? _memberData?['member_id'];
          setState(() {
            _deductionHistory.removeWhere((el) {
              if (el is! Map) return false;
              final rid = el['id'];
              return rid?.toString() == id?.toString();
            });
            _isLoading = false;
          });
          await warningDialog(context, message: labels.undoDeductionSuccess);
          if (memberId != null && mounted) {
            setState(() => _isLoading = true);
            await _fetchMemberAndPackages(int.parse(memberId.toString()));
          }
        } else {
          final errorMessage =
              (result.body is Map && result.body['extras'] != null && result.body['extras'].toString().isNotEmpty)
                  ? result.body['extras'].toString()
                  : labels.undoDeductionError;
          _showError(errorMessage);
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint('Undo deduction error: $e');
      _showError(AppLabels.current.undoDeductionError);
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Helpers ───

  String _lessonContextLines(
    TrainerScheduleCalendarEventModel e,
    AppLabels labels,
  ) {
    final localeName = AppLabels.currentLocale == SupportedLocale.tr
        ? 'tr_TR'
        : 'en_US';
    DateTime? startLocal;
    try {
      startLocal =
          DateFormatUtils.parseRandevuCalendarEventStartLocal(e.start);
    } catch (_) {}
    final dateStr = startLocal != null
        ? DateFormat.yMMMMEEEEd(localeName).format(startLocal)
        : '';
    final timeRange = DateFormatUtils.formatLocalHmRange(
      e.start,
      e.end,
      durationHours: e.durationHours,
    );
    final lines = <String>[e.title.trim()];
    if (dateStr.isNotEmpty) lines.add(dateStr);
    if (timeRange.isNotEmpty) {
      lines.add('${labels.groupLessonScheduleLessonTimeLabel}: $timeRange');
    }
    final loc = e.locationName?.trim();
    if (loc != null && loc.isNotEmpty) {
      lines.add('${labels.location}: $loc');
    }
    return lines.join('\n');
  }

  /// Müzik okulu anasayfa özeti ile aynı tip mavi altı çizili tetikleyici.
  Widget _buildAttendanceExpandToggleText({
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

  /// Ders programı kartı — girişte açıklama ile QR arası; üye görünümünde üstte.
  Widget _buildPresetLessonExpandableSection(BaseTheme theme, AppLabels labels) {
    final e = widget.presetAttendanceLesson;
    if (e == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                Icons.event_note_outlined,
                size: 26,
                color: theme.default900Color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    labels.attendancePresetLessonHeading,
                    style: theme.textLabel(color: theme.default900Color),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels.attendancePresetLessonSectionHint,
                    style: theme.textCaption(
                      color: theme.panelSubTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (!_presetLessonDetailExpanded)
          TrainerGroupLessonSchedulePeekCard(
            data: e,
            theme: theme,
            labels: labels,
            outerMargin: EdgeInsets.zero,
          )
        else
          TrainerGroupLessonScheduleCard(
            data: e,
            theme: theme,
            labels: labels,
            outerMargin: EdgeInsets.zero,
          ),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: _buildAttendanceExpandToggleText(
            theme: theme,
            text: _presetLessonDetailExpanded
                ? labels.attendanceLessonCardShowLess
                : labels.attendanceLessonCardShowMore,
            onTap: () => setState(
              () => _presetLessonDetailExpanded = !_presetLessonDetailExpanded,
            ),
          ),
        ),
      ],
    );
  }

  void _showError(String message) {
    if (mounted) {
      warningDialog(context, message: message);
    }
  }

  // ═════════════════════════════════════════════════════
  //  BUILD
  // ═════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;
    final abilityState = context.watch<MobileAbilityCubit>().state;

    if (!abilityState.canView(MobileAbilitySubjects.qrScan)) {
      return Scaffold(
        appBar: TopAppBarWidget(title: labels.attendance),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              labels.noAccessPermission,
              textAlign: TextAlign.center,
              style: theme.panelBodyStyle,
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBarWidget(tab: NavTab.home),
      );
    }

    return PopScope(
      canPop: _screenState == _ScreenState.landing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _screenState != _ScreenState.landing) {
          _backToLanding();
        }
      },
      child: Scaffold(
        backgroundColor: theme.defaultBackgroundColor,
        appBar: TopAppBarWidget(title: labels.attendance),
        body: _buildBody(theme, labels, abilityState),
        bottomNavigationBar: BottomNavigationBarWidget(tab: NavTab.home),
      ),
    );
  }

  Widget _buildBody(
      BaseTheme theme, AppLabels labels, MobileAbilityState abilityState) {
    switch (_screenState) {
      case _ScreenState.landing:
        return _buildLandingView(theme, labels);
      case _ScreenState.scanning:
        return _buildScannerView(theme, labels);
      case _ScreenState.memberView:
        return _buildMemberView(theme, labels, abilityState);
    }
  }

  // ═════════════════════════════════════════════════════
  //  LANDING VIEW
  // ═════════════════════════════════════════════════════

  Widget _buildLandingView(BaseTheme theme, AppLabels labels) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: theme.panelPagePadding,
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildLandingIcon(theme),
            const SizedBox(height: 16),
            Text(
              labels.attendance,
              style: theme.textTitle(color: theme.default900Color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                labels.attendanceDescription,
                style: theme.textCaption(color: theme.panelSubTextColor),
                textAlign: TextAlign.center,
              ),
            ),
            if (widget.presetAttendanceLesson != null) ...[
              const SizedBox(height: 20),
              _buildPresetLessonExpandableSection(theme, labels),
            ],
            const SizedBox(height: 20),
            _buildActionCard(
              theme: theme,
              icon: Icons.qr_code_scanner_rounded,
              title: labels.attendanceScanQr,
              subtitle: labels.scanMemberQr,
              onTap: _openScanner,
            ),
            const SizedBox(height: 16),
            _buildCardNumberInput(theme, labels),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCardNumberInput(BaseTheme theme, AppLabels labels) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.defaultWhiteColor,
        borderRadius: BorderRadius.circular(theme.panelCardRadius),
        border: Border.all(color: theme.default900Color.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: theme.defaultBlackColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.default900Color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.credit_card_rounded,
                    color: theme.default900Color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(labels.cardNumber,
                  style: theme.textBody(color: theme.default900Color)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _cardController,
            focusNode: _cardFocusNode,
            keyboardType: TextInputType.number,
            maxLength: 10,
            style: theme.inputTextStyle(),
            decoration: theme.inputDecoration(
              labelText: labels.enterCardNumber,
              counterText: '',
              suffixIcon: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
            onSubmitted: (_) => _searchByCardNumber(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _searchByCardNumber,
              icon: const Icon(Icons.search_rounded),
              label: Text(labels.searchMember),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.default500Color,
                foregroundColor: theme.defaultBlackColor,
                textStyle: theme.panelButtonTextStyle,
                disabledBackgroundColor: theme.defaultGray400Color,
                disabledForegroundColor: theme.defaultGray600Color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(theme.panelButtonRadius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandingIcon(BaseTheme theme) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: theme.default900Color.withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check_circle_outline_rounded,
        size: 48,
        color: theme.default900Color,
      ),
    );
  }

  Widget _buildActionCard({
    required BaseTheme theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool disabled = false,
  }) {
    final cardColor = disabled
        ? theme.panelCardBackground
        : theme.defaultWhiteColor;
    final iconColor = disabled
        ? theme.panelSubTextColor
        : theme.default900Color;
    final titleColor = disabled
        ? theme.panelSubTextColor
        : theme.default900Color;
    final subtitleColor = disabled
        ? theme.defaultGray400Color
        : theme.panelSubTextColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(theme.panelCardRadius),
          border: Border.all(
            color: disabled
                ? theme.panelDividerColor
                : theme.default900Color.withOpacity(0.12),
          ),
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: theme.defaultBlackColor.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textBody(color: titleColor)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: theme.textCaption(color: subtitleColor)),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: iconColor.withOpacity(0.4),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════
  //  SCANNER VIEW
  // ═════════════════════════════════════════════════════

  Widget _buildScannerView(BaseTheme theme, AppLabels labels) {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: Stack(
            children: [
              if (_scannerController != null)
                MobileScanner(
                  controller: _scannerController!,
                  onDetect: _onBarcodeDetected,
                ),
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.defaultWhiteColor.withOpacity(0.7),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              if (_isLoading)
                Container(
                  color: BlocTheme.theme.defaultBlackColor.withOpacity(0.54),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          color: theme.defaultBackgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code_scanner_rounded,
                  size: 36, color: theme.default900Color),
              const SizedBox(height: 8),
              Text(
                labels.scanMemberQr,
                style: theme.textBody(color: theme.default900Color),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════
  //  MEMBER VIEW (header + packages)
  // ═════════════════════════════════════════════════════

  Widget _buildMemberView(
      BaseTheme theme, AppLabels labels, MobileAbilityState abilityState) {
    return Column(
      children: [
        const SizedBox(height: 12),
        _buildMemberCard(theme),
        const SizedBox(height: 12),
        _buildMemberTabs(theme, labels),
        const SizedBox(height: 8),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _memberTabIndex == 0
                  ? _buildActivePackagesTab(theme, labels, abilityState)
                  : _buildDeductionHistoryTab(theme, labels),
        ),
        _buildBottomActions(theme, labels),
      ],
    );
  }

  Widget _buildMemberTabs(BaseTheme theme, AppLabels labels) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildTabButton(theme, labels.activePackages, 0)),
          const SizedBox(width: 10),
          Expanded(child: _buildTabButton(theme, labels.packageDeductions, 1)),
        ],
      ),
    );
  }

  Widget _buildTabButton(BaseTheme theme, String text, int index) {
    final isSelected = _memberTabIndex == index;
    return InkWell(
      onTap: () => _switchTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.default500Color : Colors.transparent,
          border: Border.all(color: isSelected ? theme.default500Color : theme.default900Color),
          borderRadius: BorderRadius.circular(theme.panelButtonRadius),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: theme.textBodyBold(
            color: isSelected
                ? theme.default900Color
                : theme.default900Color,
          ),
        ),
      ),
    );
  }

  Widget _buildActivePackagesTab(
      BaseTheme theme, AppLabels labels, MobileAbilityState abilityState) {
    if (_memberPackages.isEmpty) {
      return Center(
        child: NoDataTextWidget(
          text: labels.noActivePackage,
          color: theme.default700Color,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4),
      itemCount: _memberPackages.length,
      itemBuilder: (context, index) {
        return _buildPackageCard(
          theme,
          labels,
          _memberPackages[index],
          canBurn: abilityState.canManage(MobileAbilitySubjects.qrScan),
        );
      },
    );
  }

  Widget _buildDeductionHistoryTab(BaseTheme theme, AppLabels labels) {
    if (_deductionHistory.isEmpty) {
      return Center(
        child: NoDataTextWidget(
          text: labels.noDeductionHistory,
          color: theme.default900Color,
        ),
      );
    }
    final itemCount = _deductionHistory.length +
        (_historyCurrentPage < _historyLastPage ? 1 : 0);
    return ListView.builder(
      controller: _historyScrollController,
      padding: const EdgeInsets.only(top: 4),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index >= _deductionHistory.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.default700Color,
                ),
              ),
            ),
          );
        }
        return _buildDeductionCard(theme, labels, _deductionHistory[index]);
      },
    );
  }

  Widget _buildDeductionCard(
      BaseTheme theme, AppLabels labels, dynamic item) {
    final record = item is Map<String, dynamic> ? item : <String, dynamic>{};
    final note = record['note'] ?? '';
    final planDate = record['plan_date'] ?? '';
    final planTime = record['plan_time'] ?? '';
    final id = record['id'];

    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final isToday = planDate == todayStr;

    return InkWell(
      onTap: (isToday && id != null) ? () => _undoDeduction(record) : null,
      borderRadius: BorderRadius.circular(theme.panelCardRadius),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: BoxDecoration(
          color: theme.defaultGray100Color,
          borderRadius: BorderRadius.circular(theme.panelCardRadius),
          border: Border.all(color: theme.defaultGray300Color),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (note.toString().isNotEmpty)
                        Text(
                          note.toString(),
                          style: theme.textBodyBold(color: theme.default900Color),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 2),
                      Text(
                        '${_formatDate(planDate)}${planTime.toString().isNotEmpty ? '  $planTime' : ''}',
                        style: theme.textCaption(color: theme.defaultGray600Color),
                      ),
                    ],
                  ),
                ),
              ),
              if (isToday && id != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.undo_rounded,
                      color: theme.defaultRed700Color, size: 22),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String date) {
    if (date.isEmpty) return '';
    final parts = date.split('-');
    if (parts.length != 3) return date;
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  Widget _buildMemberCard(BaseTheme theme) {
    final memberName =
        _memberData?['name'] ?? _memberData?['full_name'] ?? '';
    final memberPhone = _memberData?['phone'] ?? '';
    final memberImage = _memberData?['image'] ?? _memberData?['photo'] ?? '';
    final hasImage = memberImage.toString().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: theme.defaultGray100Color,
        border: Border.all(color: theme.defaultGray200Color),
        borderRadius: BorderRadius.all(Radius.circular(theme.panelCardRadius)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onDoubleTap: hasImage
                ? () => ImagePopupWidget.show(
                      context,
                      imageProvider: NetworkImage(memberImage.toString()),
                    )
                : null,
            child: ClipOval(
              child: Container(
                width: 50,
                height: 50,
                color: theme.default900Color.withOpacity(0.08),
                child: hasImage
                    ? Image.network(
                        memberImage.toString(),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.person,
                          color: theme.default700Color,
                          size: 28,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        color: theme.default700Color,
                        size: 28,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memberName.toString().toUpperCase(),
                  style: theme.textBodyBold(color: theme.defaultGray700Color),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (memberPhone.toString().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    memberPhone.toString(),
                    style: theme.textCaption(color: theme.defaultGray900Color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BaseTheme theme, AppLabels labels) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _backToLanding,
            icon: const Icon(Icons.person_search_rounded),
            label: Text(labels.scanNewMember),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.default500Color,
              foregroundColor: theme.defaultBlackColor,
              textStyle: theme.panelButtonTextStyle,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(theme.panelButtonRadius),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Package Card ───

  Widget _buildPackageCard(
      BaseTheme theme, AppLabels labels, Map<String, dynamic> package,
      {bool canBurn = true}) {
    final productName = package['name'] ?? package['product_name'] ?? '';
    final remainQuantity =
        int.tryParse((package['remaining_qty'] ?? package['remain_quantity'])?.toString() ?? '0') ?? 0;
    final totalQuantity =
        int.tryParse((package['package_qty'] ?? package['total_quantity'])?.toString() ?? '0') ?? 0;
    final endDate = package['end_date'] ?? '';
    final situation = package['situation'] ?? '';
    final isDepleted = remainQuantity <= 0 || situation == 'depleted';

    return InkWell(
      onTap: (!isDepleted && canBurn) ? () => _takeAttendance(package) : null,
      child: Container(
        decoration: BoxDecoration(
          color: theme.defaultGray100Color,
          border: Border.all(color: theme.defaultGray200Color),
          borderRadius: BorderRadius.all(Radius.circular(theme.panelCardRadius)),
        ),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        height: 60,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      productName,
                      style: theme.textBodyBold(
                        color: isDepleted
                            ? theme.panelSubTextColor
                            : theme.defaultGray700Color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${labels.remainingRights}: $remainQuantity / $totalQuantity'
                      '${endDate.isNotEmpty ? '  •  $endDate' : ''}',
                      style: theme.textCaption(
                        color: isDepleted
                            ? theme.panelSubTextColor
                            : theme.defaultGray900Color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!isDepleted && canBurn)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.chevron_right_outlined,
                  color: theme.default900Color,
                  size: 28,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
