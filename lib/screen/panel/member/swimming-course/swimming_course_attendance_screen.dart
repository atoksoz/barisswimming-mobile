import 'dart:convert';

import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/constants/url/api_hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/utils/attendance_report_status_presentation.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/data/model/attendance_report_detail_item_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Yüzme kursu üye paneli — yoklama geçmişi.
///
/// **Backend:** api-system `GET v2/me/attendance-report` (JWT `v2/me/…`), randevu
/// projesine proxy; sayfalı, sunucu tarafı genelde en yeni önce (desc).
/// Liste birleşiminde tarih+saat **azalan** sıra istemci tarafında da garanti edilir.
class SwimmingCourseAttendanceScreen extends StatefulWidget {
  const SwimmingCourseAttendanceScreen({super.key});

  @override
  State<SwimmingCourseAttendanceScreen> createState() =>
      _SwimmingCourseAttendanceScreenState();
}

class _SwimmingCourseAttendanceScreenState
    extends State<SwimmingCourseAttendanceScreen> {
  static const int _itemsPerPage = 20;

  final ScrollController _scrollController = ScrollController();

  final List<AttendanceReportDetailItemModel> _items = [];
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadPage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_loading &&
        _hasMore) {
      _loadPage();
    }
  }

  int _parseLastPage(dynamic value) {
    final n = int.tryParse(value?.toString() ?? '');
    if (n == null || n < 1) return 1;
    return n;
  }

  void _sortItemsNewestFirst() {
    _items.sort(AttendanceReportDetailItemModel.compareByPlanDateTimeDesc);
  }

  Future<void> _loadPage() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);

    try {
      final config = context.read<ExternalApplicationsConfigCubit>().state;
      if (config == null || config.apiHamamspaUrl.isEmpty) {
        if (mounted) {
          setState(() {
            _hasMore = false;
            _loading = false;
            _initialLoading = false;
          });
        }
        return;
      }

      final url = ApiHamamSpaUrlConstants.getMyAttendanceReportUrl(
        config.apiHamamspaUrl,
        page: _page,
        itemsPerPage: _itemsPerPage,
      );
      final result = await RequestUtil.getJson(url);

      if (result.isSuccess && result.body is Map<String, dynamic>) {
        final body = result.body as Map<String, dynamic>;
        final output = body['output'];
        if (output is Map<String, dynamic>) {
          if (kDebugMode) {
            try {
              debugPrint(
                '[SwimmingCourseAttendance] attendance-report raw output:\n'
                '${const JsonEncoder.withIndent('  ').convert(output)}',
              );
            } catch (_) {
              debugPrint(
                '[SwimmingCourseAttendance] attendance-report output: $output',
              );
            }
          }
          final rawDetails = output['details'] as List<dynamic>? ?? [];
          final newItems = rawDetails
              .map(
                (e) => AttendanceReportDetailItemModel.fromJson(
                  Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
                ),
              )
              .toList();
          final visibleItems =
              newItems.where((e) => !e.isCancelled).toList();

          final lastPage = _parseLastPage(output['last_page']);

          if (mounted) {
            setState(() {
              _items.addAll(visibleItems);
              _sortItemsNewestFirst();
              _hasMore = _page < lastPage;
              _page++;
              _loading = false;
              _initialLoading = false;
            });
            if (visibleItems.isEmpty && _hasMore) {
              _loadPage();
            }
          }
          return;
        }
      }

      if (mounted) {
        setState(() {
          _hasMore = false;
          _loading = false;
          _initialLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasMore = false;
          _loading = false;
          _initialLoading = false;
        });
      }
    }
  }

  String _formatPlanDate(String raw) {
    if (raw.isEmpty) return '-';
    try {
      return DateFormat('dd.MM.yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

    return Scaffold(
      appBar: TopAppBarWidget(title: labels.myAttendance),
      body: _initialLoading
          ? const Center(child: LoadingIndicatorWidget())
          : CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (_items.isEmpty && !_loading)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: NoDataTextWidget(
                        text: labels.noAttendanceRecords,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < _items.length) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _buildAttendanceCard(
                                _items[index],
                                theme,
                                labels,
                              ),
                            );
                          }
                          if (index == _items.length && _loading) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: LoadingIndicatorWidget(size: 28),
                              ),
                            );
                          }
                          return null;
                        },
                        childCount: _items.length + (_loading ? 1 : 0),
                      ),
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBarWidget(tab: NavTab.home),
    );
  }

  Widget _buildAttendanceCard(
    AttendanceReportDetailItemModel item,
    BaseTheme theme,
    AppLabels labels,
  ) {
    final status =
        AttendanceReportStatusPresentation.resolve(theme, labels, item);

    return Container(
      decoration: BoxDecoration(
        color: theme.defaultWhiteColor,
        border: Border.all(color: theme.defaultGray200Color),
        borderRadius: BorderRadius.circular(theme.panelCardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.lessonName,
                    style: theme.textBody(color: theme.default900Color),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(status.icon, size: 18, color: status.color),
                      const SizedBox(width: 6),
                      Text(
                        status.label,
                        style: theme.textSmallSemiBold(color: status.color),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_showMakeupBadge(item)) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.event_repeat_outlined,
                    size: 16,
                    color: theme.panelWarningColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    labels.makeupLesson,
                    style:
                        theme.textSmallSemiBold(color: theme.panelWarningColor),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            _fieldLine(
              theme,
              Icons.person_outline,
              labels.teacher,
              item.employeeName,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _fieldInline(
                  theme,
                  Icons.calendar_today_outlined,
                  labels.date,
                  _formatPlanDate(item.date),
                ),
                const SizedBox(width: 16),
                _fieldInline(
                  theme,
                  Icons.access_time_outlined,
                  labels.time,
                  item.time ?? '-',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _showMakeupBadge(AttendanceReportDetailItemModel item) => item.isMakeup;

  Widget _fieldLine(
    BaseTheme theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.defaultGray500Color),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: theme.textSmall(color: theme.defaultGray500Color),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textSmallSemiBold(color: theme.defaultGray700Color),
          ),
        ),
      ],
    );
  }

  Widget _fieldInline(
    BaseTheme theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: theme.defaultGray500Color),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: theme.textSmall(color: theme.defaultGray500Color),
        ),
        Text(
          value,
          style: theme.textSmallSemiBold(color: theme.defaultGray700Color),
        ),
      ],
    );
  }
}
