import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_sport_life/config/announcement/announcement_cubit.dart';
import 'package:e_sport_life/config/external-applications-config/external_applications_config.dart';
import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/config/user-config/user_config.dart';
import 'package:e_sport_life/config/user-config/user_config_cubit.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/services/member_home_dashboard_service.dart';
import 'package:e_sport_life/core/utils/mobile_panel_app_settings_loader.dart';
import 'package:e_sport_life/core/utils/shared-preferences/muzik_okulum_home_cache_utils.dart';
import 'package:e_sport_life/core/services/slider_images_service.dart';
import 'package:e_sport_life/core/utils/shared-preferences/slider_utils.dart';
import 'package:e_sport_life/core/widgets/announcement_icon_widget.dart';
import 'package:e_sport_life/core/widgets/icon_button_widget.dart';
import 'package:e_sport_life/core/widgets/image_popup_widget.dart';
import 'package:e_sport_life/core/widgets/member_active_package_rights_donut_card.dart';
import 'package:e_sport_life/core/widgets/member_home_statement_chart_card.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/quick_access_section_widget.dart';
import 'package:e_sport_life/screen/panel/common/trainer/trainer_list_screen.dart';
import 'package:e_sport_life/screen/panel/member/muzik-okulum/guardian_list_screen.dart';
import 'package:e_sport_life/screen/panel/member/muzik-okulum/invoice_list_screen.dart';
import 'package:e_sport_life/screen/panel/member/muzik-okulum/lesson_schedule_screen.dart';
import 'package:e_sport_life/screen/panel/member/muzik-okulum/package_list_screen.dart';
import 'package:e_sport_life/screen/panel/member/muzik-okulum/payment_plan_list_screen.dart';
import 'package:e_sport_life/screen/panel/member/muzik-okulum/member_today_summary_popup.dart';
import 'package:e_sport_life/data/model/member_home_reminder_payment_model.dart';
import 'package:e_sport_life/screen/panel/member/muzik-okulum/statement_list_screen.dart';
import 'package:e_sport_life/screen/panel/member/swimming-course/swimming_course_attendance_screen.dart';
import 'package:e_sport_life/screen/panel/member/swimming-course/swimming_course_pools_screen.dart';
import 'package:e_sport_life/screen/panel/member/swimming-course/swimming_course_home_reminders_section.dart';
import 'package:e_sport_life/screen/panel/member/swimming-course/swimming_course_home_summary_section.dart';
import 'package:e_sport_life/screen/panel/common/suggestion-complaint/suggestion_complaint_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SwimmingCourseHomeScreen extends StatefulWidget {
  const SwimmingCourseHomeScreen({Key? key}) : super(key: key);

  @override
  State<SwimmingCourseHomeScreen> createState() => _SwimmingCourseHomeScreenState();
}

class _SwimmingCourseHomeScreenState extends State<SwimmingCourseHomeScreen> {
  static const String _cacheKeyDashboard = 'swimming_course_full_dashboard';

  String _name = '';
  ImageProvider? _imageProviderThumb;
  ImageProvider? _imageProvider;
  List<String> _sliderImages = [];
  int _sliderWaitTime = 10;

  int _todayPaymentTotal = 0;
  int _todayLessonCount = 0;
  int _todaySummaryRowCount = 0;

  MemberHomeDashboardInsights? _homeInsights;
  bool _insightsLoading = true;
  int _homeDashboardLoadGen = 0;

  MemberHomeFullDashboard? _fullDashboard;
  List<MemberHomeReminderPaymentModel> _reminderPayments = [];

  bool _quickAccessExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadMemberData();
    _loadSliderImages();
    _checkLatestAnnouncement();
    _loadMobileAppSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadHomeDashboard();
    });
  }

  Future<void> _loadMobileAppSettings() async {
    await loadMobilePanelAppSettings(context);
  }

  Future<void> _loadMemberData() async {
    try {
      await context.read<UserConfigCubit>().loadUserConfig();
      final userConfig = context.read<UserConfigCubit>().state;
      if (userConfig != null) {
        setState(() {
          final rawName = userConfig.name;
          _name = rawName.isNotEmpty ? jsonDecode('"$rawName"') : '';
          final String thumbImageUrl = userConfig.thumbImageUrl;
          final String imageUrl = userConfig.imageUrl;
          if (imageUrl.isNotEmpty &&
              imageUrl != 'null' &&
              thumbImageUrl.isNotEmpty) {
            _imageProviderThumb = Image.network(thumbImageUrl).image;
            _imageProvider = Image.network(imageUrl).image;
          }
        });
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

  void _resetTopBadgesAndInsights() {
    _todaySummaryRowCount = 0;
    _todayLessonCount = 0;
    _todayPaymentTotal = 0;
    _homeInsights = null;
    _fullDashboard = null;
    _insightsLoading = false;
    _reminderPayments = [];
  }

  Future<void> _loadHomeDashboard() async {
    final gen = ++_homeDashboardLoadGen;
    try {
      final externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      if (externalConfig == null) {
        if (!mounted) return;
        setState(_resetTopBadgesAndInsights);
        return;
      }

      final apiUrl = externalConfig.apiHamamspaUrl;
      final randevuUrl = externalConfig.onlineReservation;

      if (apiUrl.isEmpty) {
        if (!mounted) return;
        setState(_resetTopBadgesAndInsights);
        return;
      }

      // Cache kontrolü
      final cached =
          MuzikOkulumHomeCacheUtils.get<MemberHomeFullDashboard>(
              _cacheKeyDashboard);
      if (cached != null) {
        if (!mounted || gen != _homeDashboardLoadGen) return;
        _applyFullDashboard(cached);
        return;
      }

      if (mounted) {
        setState(() {
          _insightsLoading = true;
          _reminderPayments = [];
        });
      }

      final dashboard = await MemberHomeDashboardService.loadFullDashboard(
        apiUrl: apiUrl,
        randevuUrl: randevuUrl,
      );

      if (!mounted || gen != _homeDashboardLoadGen) return;

      MuzikOkulumHomeCacheUtils.set(_cacheKeyDashboard, dashboard);
      _applyFullDashboard(dashboard);
    } catch (_) {
      if (!mounted || gen != _homeDashboardLoadGen) return;
      setState(() {
        _todaySummaryRowCount = 0;
        _todayLessonCount = 0;
        _todayPaymentTotal = 0;
        _homeInsights = MemberHomeDashboardInsights.empty();
        _fullDashboard = null;
        _insightsLoading = false;
        _reminderPayments = [];
      });
    }
  }

  void _applyFullDashboard(MemberHomeFullDashboard dashboard) {
    setState(() {
      _fullDashboard = dashboard;
      _homeInsights = dashboard.insights;
      _todayLessonCount = dashboard.todayLessonCount;
      _todayPaymentTotal = dashboard.todayUnpaidPaymentCount;
      _todaySummaryRowCount =
          dashboard.todayLessonCount + dashboard.todayUnpaidPaymentCount;
      _reminderPayments = dashboard.reminderPayments;
      _insightsLoading = false;
    });
  }

  String _todayPaymentsBadgeText() => '$_todayPaymentTotal';

  @override
  Widget build(BuildContext context) {
    final BaseTheme theme = BlocTheme.theme;
    final labels = AppLabels.current;

    return BlocListener<ExternalApplicationsConfigCubit,
        ExternalApplicationsConfig?>(
      listenWhen: (previous, current) {
        final url = current?.apiHamamspaUrl ?? '';
        if (url.isEmpty) return false;
        return previous?.apiHamamspaUrl != url;
      },
      listener: (context, state) {
        MuzikOkulumHomeCacheUtils.invalidateAll();
        _loadHomeDashboard();
      },
      child: BlocListener<UserConfigCubit, UserConfig?>(
        listenWhen: (previous, current) {
          if (current == null) return false;
          if (previous == null) return true;
          return previous.token != current.token ||
              previous.memberId != current.memberId;
        },
        listener: (context, state) {
          MuzikOkulumHomeCacheUtils.invalidateAll();
          _loadHomeDashboard();
        },
        child: Scaffold(
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
                const SizedBox(height: 10),
                _buildTopButtons(theme, labels),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        if (_sliderImages.isNotEmpty) ...[
                          SizedBox(height: theme.panelHomeBlockGap),
                          _buildSlider(theme),
                        ],
                        SizedBox(height: theme.panelHomeBlockGap),
                        _buildPackageRightsDonut(theme, labels),
                        SwimmingCourseHomeSummarySection(
                          loading: _insightsLoading && _homeInsights == null,
                          insights: _homeInsights,
                          onRecentAttendanceTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const SwimmingCourseAttendanceScreen(),
                              ),
                            );
                          },
                        ),
                        SwimmingCourseHomeRemindersSection(
                          paymentReminders: _reminderPayments,
                          onOpenPaymentPlans: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PaymentPlanListScreen(
                                  showNearDuePaymentsOnly: true,
                                ),
                              ),
                            );
                          },
                        ),
                        if (!_insightsLoading || _fullDashboard != null)
                          MemberHomeStatementChartCard(
                            onTapOpenStatement: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const StatementListScreen(),
                                ),
                              );
                            },
                            externalTotalDebit:
                                _fullDashboard?.statementTotalDebit,
                            externalTotalCredit:
                                _fullDashboard?.statementTotalCredit,
                            externalBalance: _fullDashboard?.statementBalance,
                            externalItems:
                                _fullDashboard?.statementRecentItems,
                          ),
                        SizedBox(height: theme.panelHomeBlockGap),
                        _buildQuickAccessSection(theme, labels),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildPackageRightsDonut(BaseTheme theme, AppLabels labels) {
    final nearExpiry =
        _homeInsights?.nearExpiryPackages ?? const <Map<String, dynamic>>[];
    final showNearExpiry = nearExpiry.isNotEmpty;

    return MemberActivePackageRightsDonutCard(
      theme: theme,
      title: labels.homePackageRightsDonutTitle,
      remainingLegend: labels.homePackageRightsDonutRemainingLegend,
      usedLegend: labels.homePackageRightsDonutUsedLegend,
      emptyStateLine: labels.homePackageRightsDonutEmptyStateLine,
      detailedViewLabel: labels.detailedView,
      remaining: _homeInsights?.rightsTrackedRemain ?? 0,
      totalQuantity: _homeInsights?.rightsTrackedTotalQuantity ?? 0,
      loading: _insightsLoading && _homeInsights == null,
      showNearExpiryWarning: showNearExpiry,
      nearExpiryWarningLabel: labels.homePackageNearExpiryWarning,
      onTapNearExpiry: showNearExpiry
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PackageListScreen(nearExpiryOnly: true),
                ),
              );
            }
          : null,
      onTapDetailedView: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PackageListScreen(activeOnly: true),
          ),
        );
      },
    );
  }

  // ─── Header ───

  Widget _buildHeader(dynamic theme, AppLabels labels) {
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

  Widget _buildProfileAvatar(dynamic theme) {
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
                  image: _imageProviderThumb ?? _imageProvider!,
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

  // ─── Üst 3 Buton ───

  Widget _buildTopButtons(dynamic theme, AppLabels labels) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                spreadRadius: 1,
                color: BlocTheme.theme.panelScaffoldBackgroundColor,
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
                  badge: '$_todayLessonCount',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LessonScheduleScreen(),
                      ),
                    );
                  },
                  margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                ),
                iconButtonWidget(
                  icon: Icons.payments,
                  text: labels.todayMyPayments,
                  iconWidth: 45,
                  iconHeight: 40,
                  centerText: true,
                  badge: _todayPaymentsBadgeText(),
                  badgeTextDecoration: null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaymentPlanListScreen(
                          showTodayPaymentsOnly: true,
                        ),
                      ),
                    );
                  },
                  margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                ),
                iconButtonWidget(
                  icon: Icons.dashboard_customize_outlined,
                  text: labels.todaySummaryTitle,
                  iconWidth: 45,
                  iconHeight: 40,
                  centerText: true,
                  badge: '$_todaySummaryRowCount',
                  onTap: () {
                    MemberTodaySummaryPopup.show(context);
                  },
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

  Widget _buildSlider(dynamic theme) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: _sliderWaitTime),
        enlargeCenterPage: true,
        viewportFraction: 0.9,
      ),
      items: _sliderImages.map((imageUrl) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.sizeOf(context).width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: theme.defaultGray100Color,
                    child: const Center(child: Icon(Icons.broken_image)),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  // ─── Hızlı Erişim ───

  Widget _buildQuickAccessSection(BaseTheme theme, AppLabels labels) {
    final blue = theme.defaultBlue800Color;
    Widget toggleLink(String text, VoidCallback onTap) {
      return Align(
        alignment: AlignmentDirectional.bottomEnd,
        child: InkWell(
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
        ),
      );
    }

    return QuickAccessSectionWidget(
      children: [
        _buildQuickAccessRow1(theme, labels),
        if (!_quickAccessExpanded) ...[
          const SizedBox(height: 8),
          toggleLink(
            labels.homeSummaryShowMore,
            () => setState(() => _quickAccessExpanded = true),
          ),
        ] else ...[
          const SizedBox(height: 10),
          _buildQuickAccessRow2(theme, labels),
          const SizedBox(height: 10),
          _buildQuickAccessRow3(theme, labels),
          const SizedBox(height: 8),
          toggleLink(
            labels.homeSummaryShowLess,
            () => setState(() => _quickAccessExpanded = false),
          ),
        ],
      ],
    );
  }

  Widget _buildQuickAccessRow1(dynamic theme, AppLabels labels) {
    return Row(
      children: [
        iconButtonWidget(
          icon: Icons.shopping_basket_rounded,
          text: labels.packageInfo,
          iconWidth: 45,
          iconHeight: 40,
          centerText: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PackageListScreen(),
              ),
            );
          },
          margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
        ),
        iconButtonWidget(
          icon: Icons.fact_check_outlined,
          text: labels.myAttendance,
          iconWidth: 45,
          iconHeight: 40,
          centerText: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SwimmingCourseAttendanceScreen(),
              ),
            );
          },
          margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
        ),
        iconButtonWidget(
          icon: Icons.receipt_long_outlined,
          text: labels.financialStatement,
          iconWidth: 45,
          iconHeight: 40,
          centerText: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const StatementListScreen(),
              ),
            );
          },
          margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
        ),
      ],
    );
  }

  Widget _buildQuickAccessRow2(dynamic theme, AppLabels labels) {
    return Row(
      children: [
        iconButtonWidget(
          icon: theme.suggestionSvgPath,
          text: labels.suggestionComplaint,
          iconWidth: 45,
          iconHeight: 40,
          centerText: true,
          iconColor: theme.default900Color,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SuggestionComplaint(),
              ),
            );
          },
          margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
        ),
        iconButtonWidget(
          icon: Icons.payments_outlined,
          text: labels.scheduledPayments,
          iconWidth: 45,
          iconHeight: 40,
          centerText: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PaymentPlanListScreen(),
              ),
            );
          },
          margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
        ),
        iconButtonWidget(
          icon: Icons.family_restroom_outlined,
          text: labels.guardianInfo,
          iconWidth: 45,
          iconHeight: 40,
          centerText: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GuardianListScreen(),
              ),
            );
          },
          margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
        ),
      ],
    );
  }

  Widget _buildQuickAccessRow3(dynamic theme, AppLabels labels) {
    return Row(
      children: [
        iconButtonWidget(
          icon: Icons.school_outlined,
          text: labels.trainerRoster,
          iconWidth: 45,
          iconHeight: 40,
          centerText: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TrainerListScreen(),
              ),
            );
          },
          margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
        ),
        iconButtonWidget(
          icon: Icons.receipt_outlined,
          text: labels.invoiceInfo,
          iconWidth: 45,
          iconHeight: 40,
          centerText: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const InvoiceListScreen(),
              ),
            );
          },
          margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
        ),
        iconButtonWidget(
          icon: Icons.pool_outlined,
          text: labels.profileMenuSwimmingPoolsTitle,
          iconWidth: 45,
          iconHeight: 40,
          centerText: true,
          iconColor: theme.default900Color,
          onTap: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const SwimmingCoursePoolsScreen(
                  useMemberPoolEndpoint: true,
                  bottomNavTab: NavTab.home,
                ),
              ),
            );
          },
          margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
        ),
      ],
    );
  }
}
