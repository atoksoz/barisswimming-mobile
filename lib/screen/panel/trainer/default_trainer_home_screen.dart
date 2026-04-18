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
import 'package:e_sport_life/core/utils/date_format_utils.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/utils/shared-preferences/slider_utils.dart';
import 'package:e_sport_life/core/widgets/announcement_icon_widget.dart';
import 'package:e_sport_life/core/widgets/icon_button_widget.dart';
import 'package:e_sport_life/core/widgets/quick_access_section_widget.dart';
import 'package:e_sport_life/core/widgets/image_popup_widget.dart';
import 'package:e_sport_life/core/widgets/summary_popup_widget.dart';
import 'package:e_sport_life/core/widgets/warning_dialog_widget.dart';
import 'package:e_sport_life/screen/panel/common/attendance/attendance_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DefaultTrainerHomeScreen extends StatefulWidget {
  const DefaultTrainerHomeScreen({super.key});

  @override
  State<DefaultTrainerHomeScreen> createState() => _DefaultTrainerHomeScreenState();
}

class _DefaultTrainerHomeScreenState extends State<DefaultTrainerHomeScreen> {
  List<dynamic> _todayLessons = [];
  List<dynamic> _todayPtPlans = [];
  List<dynamic> _todayQuickReservations = [];
  List<dynamic> _recentReservations = [];
  bool _isLoading = true;
  bool _isEmployeeActive = true;

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
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _checkActivePersonnelIfNeeded());
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

  Future<void> _showFeatureUnavailable() async {
    if (!mounted) return;
    await warningDialog(
      context,
      message: AppLabels.current.featureNotActive,
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
        if (mounted) {
          setState(() {
            _todayLessons =
                List<dynamic>.from(data['group_lessons'] ?? []);
            _todayPtPlans =
                List<dynamic>.from(data['pt_plans'] ?? []);
            _todayQuickReservations =
                List<dynamic>.from(data['quick_reservations'] ?? []);
            _recentReservations =
                List<dynamic>.from(data['recent_reservations'] ?? []);
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

  String _todayLabel(AppLabels labels) {
    final dayLabels = [
      labels.monday, labels.tuesday, labels.wednesday,
      labels.thursday, labels.friday, labels.saturday, labels.sunday,
    ];
    return dayLabels[DateTime.now().weekday - 1];
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
                  const SizedBox(height: 10),
                  _buildTopButtons(theme, labels, abilityState),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            if (_sliderImages.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              _buildSlider(theme),
                            ],
                            const SizedBox(height: 10),
                            _buildQuickAccessSection(
                                theme, labels, abilityState),
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: _buildRecentTransactionsSection(
                                  theme, labels),
                            ),
                          ],
                        ),
                      ),
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

  // ─── Üst 3 Buton (Member panelindeki stil) ───

  Widget _buildTopButtons(BaseTheme theme, AppLabels labels,
      MobileAbilityState abilityState) {
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
            border: Border.all(
                color: theme.panelScaffoldBackgroundColor),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          width: MediaQuery.sizeOf(context).width - 40,
          height: 120,
          child: Row(
            children: [
              if (abilityState.canView(MobileAbilitySubjects.groupLesson))
                iconButtonWidget(
                  icon: theme.groupLessonSvgPath,
                  text: labels.groupLesson,
                  iconWidth: 45,
                  iconHeight: 40,
                  centerText: true,
                  iconColor: theme.default900Color,
                  badge: '${_todayLessons.length}',
                  onTap: () {
                    if (!_guardActive()) return;
                    _showSummaryPopup(
                      theme,
                      labels.todayGroupLessons,
                      _todayLessons,
                      _buildLessonPopupItem,
                    );
                  },
                  margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                ),
              if (abilityState
                  .canView(MobileAbilitySubjects.quickReservation))
                iconButtonWidget(
                  icon: theme.resarvationNowSvgPath,
                  text: labels.quickReservation,
                  iconWidth: 45,
                  iconHeight: 40,
                  centerText: true,
                  iconColor: theme.default900Color,
                  badge: '${_todayQuickReservations.length}',
                  onTap: () {
                    if (!_guardActive()) return;
                    _showSummaryPopup(
                      theme,
                      labels.todayQuickReservations,
                      _todayQuickReservations,
                      _buildReservationPopupItem,
                    );
                  },
                  margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                ),
              if (abilityState.canView(MobileAbilitySubjects.pt))
                iconButtonWidget(
                  icon: theme.personalTrainingSvgPath,
                  text: 'PT',
                  iconWidth: 45,
                  iconHeight: 40,
                  centerText: true,
                  iconColor: theme.default900Color,
                  badge: '${_todayPtPlans.length}',
                  onTap: () {
                    if (!_guardActive()) return;
                    _showSummaryPopup(
                      theme,
                      labels.todayPtReservations,
                      _todayPtPlans,
                      _buildPtPopupItem,
                    );
                  },
                  margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Summary Popup ───

  void _showSummaryPopup(
    BaseTheme theme,
    String title,
    List<dynamic> items,
    Widget Function(BaseTheme, Map<String, dynamic>) itemBuilder,
  ) {
    final labels = AppLabels.current;
    showDialog(
      context: context,
      builder: (_) => SummaryPopupWidget(
        title: title,
        subtitle: _todayLabel(labels),
        items: items,
        itemBuilder: itemBuilder,
      ),
    );
  }

  Widget _buildLessonPopupItem(BaseTheme theme, Map<String, dynamic> item) {
    final name = item['service_name'] ?? item['name'] ?? '';
    final start = item['start_time'] ?? '';
    final end = item['end_time'] ?? '';
    final location = item['location_name'] ?? '';
    final count = item['enrollment_count'] ?? item['enrollments_count'] ?? 0;
    final capacity = item['capacity'] ?? item['max_capacity'] ?? '-';
    final enrolledMembers =
        List<dynamic>.from(item['enrolled_members'] ?? [])
          ..sort((a, b) => ((a is Map ? a['name'] : '') ?? '')
              .toString()
              .compareTo(((b is Map ? b['name'] : '') ?? '').toString()));

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(left: 12, bottom: 8),
        iconColor: theme.default700Color,
        collapsedIconColor: theme.default700Color,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style:
                          theme.textBodyBold(color: theme.defaultBlackColor)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 14, color: theme.defaultGray500Color),
                      const SizedBox(width: 4),
                      Text('$start - $end',
                          style: theme.textSmallNormal(
                              color: theme.defaultGray600Color)),
                      if (location.toString().isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Icon(Icons.location_on,
                            size: 14, color: theme.defaultGray500Color),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(location.toString(),
                              style: theme.textSmallNormal(
                                  color: theme.defaultGray600Color),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.default100Color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$count/$capacity',
                  style:
                      theme.textSmallSemiBold(color: theme.default700Color)),
            ),
          ],
        ),
        children: enrolledMembers.isEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    AppLabels.current.noData,
                    style:
                        theme.textSmallNormal(color: theme.defaultGray500Color),
                  ),
                ),
              ]
            : enrolledMembers.map<Widget>((member) {
                final m = member is Map<String, dynamic>
                    ? member
                    : <String, dynamic>{};
                final memberName = m['name'] ?? '-';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.person_outline,
                          size: 16, color: theme.defaultGray500Color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          memberName.toString(),
                          style: theme.textSmallNormal(
                              color: theme.defaultBlackColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
      ),
    );
  }

  Widget _buildReservationPopupItem(
      BaseTheme theme, Map<String, dynamic> item) {
    final name = item['member_name'] ?? item['name'] ?? '-';
    final planTime = item['plan_time'] ?? item['start_time'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(Icons.person_outline,
              size: 20, color: theme.defaultGray500Color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name.toString(),
                style: theme.textBody(color: theme.defaultBlackColor)),
          ),
          if (planTime.toString().isNotEmpty)
            Text(planTime.toString(),
                style: theme.textSmallNormal(
                    color: theme.defaultGray600Color)),
        ],
      ),
    );
  }

  Widget _buildPtPopupItem(BaseTheme theme, Map<String, dynamic> item) {
    final name = item['name'] ?? 'PT';
    final times = List<dynamic>.from(item['times'] ?? []);
    final timeText = times.isNotEmpty ? times.join(', ') : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(Icons.fitness_center,
              size: 20, color: theme.defaultGray500Color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name.toString(),
                style: theme.textBody(color: theme.defaultBlackColor)),
          ),
          if (timeText.isNotEmpty)
            Text(timeText,
                style: theme.textSmallNormal(
                    color: theme.defaultGray600Color)),
        ],
      ),
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

  // ─── Quick Access ───

  Widget _buildQuickAccessSection(
      BaseTheme theme, AppLabels labels, MobileAbilityState abilityState) {
    return QuickAccessSectionWidget(
      children: [
        _buildQuickAccessRow1(theme, labels, abilityState),
        const SizedBox(height: 10),
        _buildQuickAccessRow2(theme, labels, abilityState),
        if (abilityState.canView(MobileAbilitySubjects.memberCard) ||
            abilityState.canView(MobileAbilitySubjects.qrScan)) ...[
          const SizedBox(height: 10),
          _buildQuickAccessRow3(theme, labels, abilityState),
        ],
      ],
    );
  }

  Widget _buildQuickAccessRow1(
      BaseTheme theme, AppLabels labels, MobileAbilityState abilityState) {
    return Row(
      children: [
        if (abilityState.canView(MobileAbilitySubjects.groupLesson))
          iconButtonWidget(
            icon: theme.groupLessonSvgPath,
            text: labels.groupLesson,
            iconWidth: 45,
            iconHeight: 40,
            centerText: true,
            onTap: () {
              if (!_guardActive()) return;
              _showFeatureUnavailable();
            },
            margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
          ),
        if (abilityState.canView(MobileAbilitySubjects.pt))
          iconButtonWidget(
            icon: theme.personalTrainingSvgPath,
            text: labels.personalTraining,
            iconWidth: 45,
            iconHeight: 40,
            centerText: true,
            onTap: () {
              if (!_guardActive()) return;
              _showFeatureUnavailable();
            },
            margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
          ),
        if (abilityState.canView(MobileAbilitySubjects.quickReservation))
          iconButtonWidget(
            icon: theme.resarvationNowSvgPath,
            text: labels.quickReservation,
            iconWidth: 45,
            iconHeight: 40,
            centerText: true,
            onTap: () {
              if (!_guardActive()) return;
              _showFeatureUnavailable();
            },
            margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
          ),
      ],
    );
  }

  Widget _buildQuickAccessRow2(
      BaseTheme theme, AppLabels labels, MobileAbilityState abilityState) {
    return Row(
      children: [
        if (abilityState.canView(MobileAbilitySubjects.fitnessProgram))
          iconButtonWidget(
            icon: theme.fitnessProgrameSvgPath,
            text: labels.exerciseList,
            iconWidth: 45,
            iconHeight: 40,
            centerText: true,
            onTap: () {
              if (!_guardActive()) return;
              _showFeatureUnavailable();
            },
            margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
          ),
        if (abilityState.canView(MobileAbilitySubjects.bodyMeasurement))
          iconButtonWidget(
            icon: theme.measurementSvgPath,
            text: labels.measurementInfo,
            iconWidth: 45,
            iconHeight: 40,
            centerText: true,
            onTap: () {
              if (!_guardActive()) return;
              _showFeatureUnavailable();
            },
            margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
          ),
        if (abilityState.canView(MobileAbilitySubjects.diet))
          iconButtonWidget(
            icon: theme.dietSvgPath,
            text: labels.nutritionInfo,
            iconWidth: 45,
            iconHeight: 40,
            centerText: true,
            onTap: () {
              if (!_guardActive()) return;
              _showFeatureUnavailable();
            },
            margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
          ),
      ],
    );
  }

  Widget _buildQuickAccessRow3(
      BaseTheme theme, AppLabels labels, MobileAbilityState abilityState) {
    final buttons = <Widget>[];
    if (abilityState.canView(MobileAbilitySubjects.memberCard)) {
      buttons.add(iconButtonWidget(
        icon: theme.userSvgPath,
        text: labels.memberCard,
        iconWidth: 45,
        iconHeight: 40,
        centerText: true,
        onTap: () {
          if (!_guardActive()) return;
          _showFeatureUnavailable();
        },
        margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
      ));
    }
    if (abilityState.canView(MobileAbilitySubjects.qrScan)) {
      buttons.add(iconButtonWidget(
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
            MaterialPageRoute<void>(builder: (_) => const AttendanceScreen()),
          ).then((_) {
            if (mounted) _loadTodaySummary();
          });
        },
        margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
      ));
    }
    while (buttons.length < 3) {
      buttons.add(Expanded(
        child: Container(margin: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0)),
      ));
    }
    return Row(children: buttons);
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
