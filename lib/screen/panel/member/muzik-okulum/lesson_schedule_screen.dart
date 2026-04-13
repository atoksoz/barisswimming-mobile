import 'dart:convert';

import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/constants/url/api_hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/constants/url/randevu_al_url_constants.dart';
import 'package:e_sport_life/core/services/member_today_summary_service.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/day_selector_widget.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/core/widgets/panel_member_lesson_card_widget.dart';
import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LessonScheduleScreen extends StatefulWidget {
  const LessonScheduleScreen({
    Key? key,
    /// 1 = Pazartesi … 7 = Pazar ([DateTime.weekday]). null → bugün.
    this.initialWeekday,
  }) : super(key: key);

  final int? initialWeekday;

  @override
  State<LessonScheduleScreen> createState() => _LessonScheduleScreenState();
}

class _LessonScheduleScreenState extends State<LessonScheduleScreen> {
  late int _selectedDay;
  bool _loading = true;
  List<Map<String, dynamic>> _allEnrollments = [];
  List<Map<String, dynamic>> _todayMakeupEnrollments = [];

  @override
  void initState() {
    super.initState();
    final w = widget.initialWeekday;
    _selectedDay = (w != null && w >= 1 && w <= 7)
        ? w
        : DateTime.now().weekday;
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    setState(() => _loading = true);
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      if (externalApplicationConfig == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final url = RandevuAlUrlConstants.getMyScheduleUrl(
          externalApplicationConfig.onlineReservation);
      final token = await JwtStorageService.getToken();
      if (token == null || token.isEmpty) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final apiUrl = externalApplicationConfig.apiHamamspaUrl;
      final scheduleFuture = RequestUtil.get(url, token: token);
      final attendanceFuture = apiUrl.isNotEmpty
          ? RequestUtil.getJson(
              ApiHamamSpaUrlConstants.getMyAttendanceReportUrl(
                apiUrl,
                page: 1,
                itemsPerPage: 50,
              ),
            )
          : Future<dynamic>.value(null);

      final results = await Future.wait([scheduleFuture, attendanceFuture]);
      final scheduleRes = results[0];
      final attendanceRes = results[1] as ApiResponse?;

      if (scheduleRes != null) {
        final decoded = json.decode((scheduleRes as dynamic).body as String);
        final List items = decoded['output'] ?? [];
        _allEnrollments =
            items.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        _allEnrollments = [];
      }

      _todayMakeupEnrollments =
          MemberTodaySummaryService.parseTodayMakeupEnrollmentsFromAttendance(
        attendanceRes,
        DateTime.now(),
      );
    } catch (e) {
      debugPrint('LessonScheduleScreen fetch error: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  List<Map<String, dynamic>> _getLessonsForDay(int dayNumber) {
    return MemberTodaySummaryService.mergeScheduleEnrollmentsWithTodayMakeup(
      scheduleEnrollments: _allEnrollments,
      todayMakeupEnrollments: _todayMakeupEnrollments,
      selectedDay: dayNumber,
    );
  }

  void _onDayChanged(int day) {
    setState(() {
      _selectedDay = day;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;
    final dayLessons = _getLessonsForDay(_selectedDay);

    return Scaffold(
      appBar: TopAppBarWidget(
          title: labels.lessonSchedule.replaceAll('\n', ' ')),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: DaySelector(
              selectedDay: _selectedDay,
              onDayChanged: _onDayChanged,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: LoadingIndicatorWidget())
                : dayLessons.isEmpty
                    ? const Center(child: NoDataTextWidget())
                    : _buildLessonList(dayLessons, theme, labels),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(tab: NavTab.home),
    );
  }

  Widget _buildLessonList(
    List<Map<String, dynamic>> lessons,
    BaseTheme theme,
    AppLabels labels,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        return _buildLessonCard(lessons[index], theme, labels);
      },
    );
  }

  Widget _buildLessonCard(
    Map<String, dynamic> data,
    BaseTheme theme,
    AppLabels labels,
  ) {
    final String name = data['service_plan_name'] ?? '';
    final String employeeName = data['employee_name'] ?? '';
    final String? employeeImage = data['employee_image'];
    final String time = data['time'] ?? '';
    final String? locationName = data['location_name'];
    final int personLimit = data['person_limit'] ?? 0;
    final bool isMakeup = data['_is_makeup'] == true;

    return PanelMemberLessonCard(
      theme: theme,
      topBadgeLabel: labels.summaryRowBadgeMyLessons,
      lessonName: name,
      teacherName: employeeName,
      teacherImageUrl: employeeImage,
      footerPrimaryText: time,
      footerLocation: locationName,
      showMakeupBadge: isMakeup,
      makeupLabelText: labels.makeupLesson,
      personLimit: personLimit > 0 ? personLimit : null,
      margin: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 10),
    );
  }
}
