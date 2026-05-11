import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_sport_life/config/ability/mobile_ability_cubit.dart';
import 'package:e_sport_life/config/announcement/announcement_cubit.dart';
import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/config/user-config/user_config_cubit.dart';
import 'package:e_sport_life/core/constants/mobile_ability_subjects.dart';
import 'package:e_sport_life/core/constants/url/randevu_al_url_constants.dart';
import 'package:e_sport_life/core/enums/mobile_user_type.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/services/slider_images_service.dart';
import 'package:e_sport_life/core/utils/mobile_panel_app_settings_loader.dart';
import 'package:e_sport_life/core/utils/date_format_utils.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/utils/shared-preferences/slider_utils.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/announcement_icon_widget.dart';
import 'package:e_sport_life/core/widgets/icon_button_widget.dart';
import 'package:e_sport_life/core/widgets/quick_access_section_widget.dart';
import 'package:e_sport_life/core/widgets/image_popup_widget.dart';
import 'package:e_sport_life/core/widgets/warning_dialog_widget.dart';
import 'package:e_sport_life/data/model/common/trainer_today_dashboard_model.dart';
import 'package:e_sport_life/screen/panel/common/attendance/attendance_screen.dart';
import 'package:e_sport_life/screen/panel/member/swimming-course/swimming_course_pools_screen.dart';
import 'package:e_sport_life/screen/panel/trainer/common/lesson_schedule/trainer_lesson_schedule_screen.dart';
import 'package:e_sport_life/screen/panel/trainer/common/trainer_today_dashboard_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SwimmingCourseTrainerHomeScreen extends StatefulWidget {
  const SwimmingCourseTrainerHomeScreen({super.key});

  @override
  State<SwimmingCourseTrainerHomeScreen> createState() => _SwimmingCourseTrainerHomeScreenState();
}

class _SwimmingCourseTrainerHomeScreenState extends State<SwimmingCourseTrainerHomeScreen> {
  List<dynamic> _recentReservations = [];
  TrainerTodayDashboardModel? _todayDashboard;
  bool _isLoading = true;
  bool _isEmployeeActive = true;

  /// Anasayfa üst kart rozetleri — Randevu `today-summary`.
  int _trainerHomeTodayLessonsCount = 0;
  int _trainerHomeTodayAttendanceCount = 0;
  int _trainerHomeTodaySummaryCount = 0;

  String _name = "";
  ImageProvider? _imageProviderThumb;
  ImageProvider? _imageProvider;
  List<String> _sliderImages = [];
  int _sliderWaitTime = 10;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadMemberData();
    _loadSliderImages();
    _checkLatestAnnouncement();
    _loadMobileAppSettings();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _checkActivePersonnelIfNeeded());
  }

  Future<void> _loadMobileAppSettings() async {
    await loadMobilePanelAppSettings(context);
  }

  Future<void> _checkActivePersonnelIfNeeded() async {
    if (!mounted) return;
    final config = context.read<UserConfigCubit>().state;
    if (config == null) return;
    final t = config.userType;
    if (t != MobileUserType.trainer && t != MobileUserType.moderator) return;
  }

  bool _guardActive() {
    if (_isEmployeeActive) return true;
    _showAccountPassiveWarning();
    return false;
  }

  Future<void> _showAccountPassiveWarning() async {
    if (!mounted) return;
    await warningDialog(
      context,
      message: AppLabels.current.accountPassiveWarning,
      path: BlocTheme.theme.attentionSvgPath,
      buttonColor: BlocTheme.theme.default500Color,
      buttonTextColor: BlocTheme.theme.defaultBlackColor,
    );
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _loadTodaySummary();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadTodaySummary() async {
    try {
      final externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      if (externalConfig == null) return;
      final url = RandevuAlUrlConstants.getTodaySummaryUrl(
          externalConfig.onlineReservation);
      final result = await RequestUtil.getJson(url);
      if (result.isSuccess && result.output != null && result.output is Map<String, dynamic>) {
        final data = result.output as Map<String, dynamic>;
        final dashboard = TrainerTodayDashboardModel.fromJson(data);
        if (mounted) {
          setState(() {
            _todayDashboard = dashboard;
            _recentReservations = dashboard.recentReservations
                .map((e) => e.toRecentListMap())
                .toList();
            _trainerHomeTodayLessonsCount = dashboard.lessonsBadgeCount;
            _trainerHomeTodayAttendanceCount = dashboard.attendanceBadgeCount;
            _trainerHomeTodaySummaryCount = dashboard.summaryBadgeCount;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _loadMemberData() async {
    try {
      await context.read<UserConfigCubit>().loadUserConfig();
      final userConfig = context.read<UserConfigCubit>().state;
      if (userConfig != null) {
        setState(() {
          final rawName = userConfig.name;
          _name = jsonDecode('"$rawName"');
          final String thumbImageUrl = userConfig.thumbImageUrl;
          final String imageUrl = userConfig.imageUrl;
          if (imageUrl.isNotEmpty &&
              imageUrl != "null" &&
              thumbImageUrl.isNotEmpty) {
            _imageProviderThumb = Image.network(thumbImageUrl).image;
            _imageProvider = Image.network(imageUrl).image;
          }
        });
      }
      _loadEmployeeStatus();
    } catch (_) {}
  }

  Future<void> _loadEmployeeStatus() async {
    try {
      final externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      if (externalConfig == null) return;
      final url = RandevuAlUrlConstants.getTrainerProfileUrl(
          externalConfig.onlineReservation);
      final result = await RequestUtil.getJson(url);
      if (result.isSuccess && result.outputMap != null) {
        final isActive = result.outputMap!['is_active'] == true;
        if (mounted) setState(() => _isEmployeeActive = isActive);
      }
    } catch (_) {}
  }

  Future<void> _loadSliderImages() async {
    try {
      var result = await getSliderScreenItems();
      var waitTime = await getSliderWaitTime();
      if (result != null && result.isNotEmpty) {
        setState(() {
          _sliderImages = List<String>.from(result);
          _sliderWaitTime = waitTime;
        });
      }
    } catch (_) {
    } finally {
      SliderImagesService.fetchAndStoreSliderImagesData(context);
    }
  }

  Future<void> _checkLatestAnnouncement() async {
    try {
      final externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      if (externalConfig == null) return;
      final apiUrl = externalConfig.apiHamamspaUrl;
      if (apiUrl.isEmpty) return;
      final token = await JwtStorageService.getToken();
      if (token == null || token.isEmpty) return;
      context.read<AnnouncementCubit>().checkLatestAnnouncement(
            apiHamamSpaUrl: apiUrl,
            token: token,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

    return BlocBuilder<MobileAbilityCubit, MobileAbilityState>(
      builder: (context, abilityState) {
        return Scaffold(
          body: Stack(
            children: [
              SizedBox(
                height: 230,
                width: double.infinity,
                child: SvgPicture.asset(
                  theme.topBgSvgPath,
                  fit: BoxFit.cover,
                ),
              ),
              Column(
                children: [
                  _buildHeader(theme, labels),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_sliderImages.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildSlider(theme),
                        ],
                        const SizedBox(height: 10),
                        _buildTopSummaryCards(theme, labels),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _loadData,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 10),
                                  _buildQuickAccessSection(
                                    theme,
                                    labels,
                                    abilityState,
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: _buildRecentTransactionsSection(
                                      theme,
                                      labels,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Header ───

  Widget _buildHeader(BaseTheme theme, AppLabels labels) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Text(
                    labels.welcome,
                    maxLines: 1,
                    style: theme.textSubtitle(color: theme.defaultBlackColor),
                  ),
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: Text(
                    _name,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTitle(color: theme.defaultBlackColor),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnnouncementIconWidget(),
              const SizedBox(width: 12),
              _buildProfileAvatar(theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileAvatar(BaseTheme theme) {
    return GestureDetector(
      onTap: _imageProvider != null
          ? () => showDialog(
                context: context,
                barrierDismissible: true,
                builder: (_) =>
                    ImagePopupWidget(imageProvider: _imageProvider),
              )
          : null,
      child: _imageProvider != null
          ? ClipOval(
              child: Container(
                width: 55,
                height: 55,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Image(
                  image: _imageProviderThumb!,
                  fit: BoxFit.cover,
                ),
              ),
            )
          : SvgPicture.asset(
              theme.userSvgPath,
              fit: BoxFit.contain,
              width: 55,
              height: 55,
            ),
    );
  }

  // ─── Üst özet kartları (müzik okulu üye anasayfa üst üçlüsü stili) ───

  Widget _buildTopSummaryCards(BaseTheme theme, AppLabels labels) {
    void openLessonSchedule() {
      if (!_guardActive()) return;
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => TrainerLessonScheduleScreen(
            initialWeekday: DateTime.now().weekday,
          ),
        ),
      );
    }

    void openTodayAttendancePopup() {
      if (!_guardActive()) return;
      final d = _todayDashboard;
      if (d == null) return;
      TrainerTodayDashboardDialogs.showTodayAttendance(context, d);
    }

    void openTodaySummaryPopup() {
      if (!_guardActive()) return;
      final d = _todayDashboard;
      if (d == null) return;
      TrainerTodayDashboardDialogs.showTodaySummary(context, d);
    }

    return Row(
      children: [
        Container(
          margin: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                spreadRadius: 1,
                color: theme.panelScaffoldBackgroundColor,
              ),
            ],
            color: theme.defaultWhiteColor,
            border: Border.all(color: theme.defaultGray300Color, width: 1),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          width: MediaQuery.sizeOf(context).width - 40,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                iconButtonWidget(
                  icon: Icons.calendar_month_outlined,
                  text: labels.todayMyLessons,
                  iconWidth: 45,
                  iconHeight: 40,
                  centerText: true,
                  badge: '$_trainerHomeTodayLessonsCount',
                  onTap: openLessonSchedule,
                  margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                ),
                iconButtonWidget(
                  icon: Icons.fact_check_outlined,
                  text: labels.trainerHomeTodayAttendanceTitle,
                  iconWidth: 45,
                  iconHeight: 40,
                  centerText: true,
                  badge: '$_trainerHomeTodayAttendanceCount',
                  onTap: openTodayAttendancePopup,
                  margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                ),
                iconButtonWidget(
                  icon: Icons.dashboard_customize_outlined,
                  text: labels.todaySummaryTitle,
                  iconWidth: 45,
                  iconHeight: 40,
                  centerText: true,
                  badge: '$_trainerHomeTodaySummaryCount',
                  onTap: openTodaySummaryPopup,
                  margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Slider ───

  Widget _buildSlider(BaseTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.defaultWhiteColor,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: MediaQuery.sizeOf(context).width - 40,
      height: 150,
      child: CarouselSlider(
        options: CarouselOptions(
          onPageChanged: (_, __) {},
          autoPlay: true,
          autoPlayInterval: Duration(seconds: _sliderWaitTime),
          viewportFraction: 1.0,
          enlargeCenterPage: false,
        ),
        items: _sliderImages.map<Widget>((url) {
          return Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(url),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Hızlı erişim — satır başına en fazla 3 ikon; Havuzlar alt satırda ───

  Widget _buildQuickAccessSection(
      BaseTheme theme, AppLabels labels, MobileAbilityState abilityState) {
    void openLessonSchedule() {
      if (!_guardActive()) return;
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => TrainerLessonScheduleScreen(
            initialWeekday: DateTime.now().weekday,
          ),
        ),
      );
    }

    void openPools() {
      if (!_guardActive()) return;
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => const SwimmingCoursePoolsScreen(
            useMemberPoolEndpoint: false,
            bottomNavTab: NavTab.home,
          ),
        ),
      );
    }

    final canAttendance =
        abilityState.canView(MobileAbilitySubjects.qrScan);

    Widget poolsButton() => iconButtonWidget(
          icon: Icons.pool_outlined,
          text: labels.profileMenuSwimmingPoolsTitle,
          iconWidth: 45,
          iconHeight: 40,
          centerText: true,
          iconColor: theme.default900Color,
          onTap: openPools,
          margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
          expandInRow: false,
        );

    return QuickAccessSectionWidget(
      children: [
        Row(
          children: [
            if (canAttendance) ...[
              iconButtonWidget(
                icon: Icons.check_circle_outline,
                text: labels.attendance,
                iconWidth: 45,
                iconHeight: 40,
                centerText: true,
                iconColor: theme.default900Color,
                onTap: () {
                  if (!_guardActive()) return;
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const AttendanceScreen(),
                    ),
                  ).then((_) {
                    if (mounted) _loadTodaySummary();
                  });
                },
                margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
              ),
              iconButtonWidget(
                icon: Icons.qr_code_scanner_rounded,
                text: labels.trainerQuickAccessAttendanceByQrTitle,
                iconWidth: 45,
                iconHeight: 40,
                centerText: true,
                iconColor: theme.default900Color,
                onTap: () {
                  if (!_guardActive()) return;
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const AttendanceScreen(
                        openScannerOnLaunch: true,
                      ),
                    ),
                  ).then((_) {
                    if (mounted) _loadTodaySummary();
                  });
                },
                margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
              ),
              iconButtonWidget(
                icon: Icons.calendar_month_outlined,
                text: labels.profileMenuLessonScheduleTitle,
                iconWidth: 45,
                iconHeight: 40,
                centerText: true,
                iconColor: theme.default900Color,
                onTap: openLessonSchedule,
                margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
              ),
            ] else ...[
              iconButtonWidget(
                icon: Icons.calendar_month_outlined,
                text: labels.profileMenuLessonScheduleTitle,
                iconWidth: 45,
                iconHeight: 40,
                centerText: true,
                iconColor: theme.default900Color,
                onTap: openLessonSchedule,
                margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [poolsButton()],
        ),
      ],
    );
  }

  // ─── Recent Transactions ───

  List<dynamic> _sortedRecentReservations() {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final todayItems = <dynamic>[];
    final futureItems = <dynamic>[];
    final pastItems = <dynamic>[];

    for (final r in _recentReservations) {
      final date = (r is Map ? r['plan_date'] : '') ?? '';
      if (date == todayStr) {
        todayItems.add(r);
      } else if (date.compareTo(todayStr) > 0) {
        futureItems.add(r);
      } else {
        pastItems.add(r);
      }
    }

    return [...todayItems, ...futureItems, ...pastItems];
  }

  Widget _buildRecentTransactionsSection(BaseTheme theme, AppLabels labels) {
    final sorted = _sortedRecentReservations();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(labels.recentTransactions, style: theme.panelTitleStyle),
        ),
        if (sorted.isEmpty)
          _buildEmptyState(theme, labels.noRecentTransactions)
        else
          ...List.generate(sorted.length, (i) {
            final item = sorted[i] is Map<String, dynamic>
                ? sorted[i] as Map<String, dynamic>
                : <String, dynamic>{};
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRecentItem(theme, item),
                if (i < sorted.length - 1)
                  Divider(
                    color: theme.default700Color.withOpacity(0.15),
                    height: 1,
                    indent: 12,
                    endIndent: 12,
                  ),
              ],
            );
          }),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRecentItem(BaseTheme theme, Map<String, dynamic> item) {
    final memberName = item['member_name'] ?? '-';
    final planName = item['plan_name'] ?? '';
    final note = item['note'] ?? '';
    final planDate = item['plan_date'] ?? '';
    final planTime = item['plan_time'] ?? '';

    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final isPast = planDate.toString().compareTo(todayStr) < 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPast ? theme.defaultGray400Color : theme.default900Color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memberName.toString(),
                  style: isPast
                      ? theme
                          .textBodyBold(color: theme.defaultGray500Color)
                          .copyWith(decoration: TextDecoration.lineThrough)
                      : theme.textBodyBold(color: theme.defaultBlackColor),
                  overflow: TextOverflow.ellipsis,
                ),
                if (note.toString().isNotEmpty)
                  Text(
                    note.toString(),
                    style: isPast
                        ? theme
                            .textSmallNormal(color: theme.defaultGray400Color)
                            .copyWith(decoration: TextDecoration.lineThrough)
                        : theme.textSmallNormal(
                            color: theme.defaultGray600Color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (planName.toString().isNotEmpty && note.toString().isEmpty)
                  Text(
                    planName.toString(),
                    style: isPast
                        ? theme
                            .textSmallNormal(color: theme.defaultGray400Color)
                            .copyWith(decoration: TextDecoration.lineThrough)
                        : theme.textSmallNormal(
                            color: theme.defaultGray600Color),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormatUtils.formatDate(planDate.toString()),
                style: isPast
                    ? theme
                        .textSmallNormal(color: theme.defaultGray400Color)
                        .copyWith(decoration: TextDecoration.lineThrough)
                    : theme.textSmallNormal(color: theme.defaultGray500Color),
              ),
              if (planTime.toString().isNotEmpty)
                Text(
                  planTime.toString(),
                  style: isPast
                      ? theme
                          .textSmallNormal(color: theme.defaultGray400Color)
                          .copyWith(decoration: TextDecoration.lineThrough)
                      : theme.textSmallNormal(
                          color: theme.defaultGray500Color),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Empty State ───

  Widget _buildEmptyState(BaseTheme theme, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: theme.panelCardBackground,
        borderRadius: BorderRadius.circular(theme.panelCardInnerRadius),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: theme.panelSubtitleStyle,
      ),
    );
  }
}
