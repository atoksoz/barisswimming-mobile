import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/constants/url/api_hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class PackageDetailScreen extends StatefulWidget {
  final int packageId;
  final String packageName;

  const PackageDetailScreen({
    Key? key,
    required this.packageId,
    required this.packageName,
  }) : super(key: key);

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  static const int _itemsPerPage = 20;

  int _selectedTab = 0;

  final ScrollController _reservationsScrollController = ScrollController();
  final ScrollController _logsScrollController = ScrollController();

  List<Map<String, dynamic>> _reservations = [];
  int _reservationsPage = 1;
  bool _reservationsLoading = false;
  bool _reservationsHasMore = true;
  bool _reservationsInitialLoading = true;

  List<Map<String, dynamic>> _logs = [];
  int _logsPage = 1;
  bool _logsLoading = false;
  bool _logsHasMore = true;
  bool _logsInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _reservationsScrollController.addListener(_onReservationsScroll);
    _logsScrollController.addListener(_onLogsScroll);
    _loadReservationsPage();
    _loadLogsPage();
  }

  @override
  void dispose() {
    _reservationsScrollController.dispose();
    _logsScrollController.dispose();
    super.dispose();
  }

  void _onReservationsScroll() {
    if (!_reservationsScrollController.hasClients) return;
    if (_reservationsScrollController.position.pixels >=
            _reservationsScrollController.position.maxScrollExtent - 200 &&
        !_reservationsLoading &&
        _reservationsHasMore) {
      _loadReservationsPage();
    }
  }

  void _onLogsScroll() {
    if (!_logsScrollController.hasClients) return;
    if (_logsScrollController.position.pixels >=
            _logsScrollController.position.maxScrollExtent - 200 &&
        !_logsLoading &&
        _logsHasMore) {
      _loadLogsPage();
    }
  }

  int _parseLastPage(dynamic value) {
    final n = int.tryParse(value?.toString() ?? '');
    if (n == null || n < 1) return 1;
    return n;
  }

  Future<void> _loadReservationsPage() async {
    if (_reservationsLoading || !_reservationsHasMore) return;
    setState(() => _reservationsLoading = true);

    try {
      final config = context.read<ExternalApplicationsConfigCubit>().state;
      if (config == null || config.apiHamamspaUrl.isEmpty) {
        if (mounted) {
          setState(() {
            _reservationsHasMore = false;
            _reservationsLoading = false;
            _reservationsInitialLoading = false;
          });
        }
        return;
      }

      final url = ApiHamamSpaUrlConstants.getMyPackageReservationsUrl(
        config.apiHamamspaUrl,
        widget.packageId,
        page: _reservationsPage,
        itemsPerPage: _itemsPerPage,
      );
      final result = await RequestUtil.getJson(url);

      if (result.isSuccess && result.body is Map<String, dynamic>) {
        final body = result.body as Map<String, dynamic>;
        final output = body['output'];
        List<dynamic> raw = [];
        var lastPage = 1;

        if (output is Map<String, dynamic>) {
          if (output['reservations'] is List) {
            raw = output['reservations'] as List<dynamic>;
          }
          lastPage = _parseLastPage(output['last_page']);
        } else if (body['reservations'] is List) {
          raw = body['reservations'] as List<dynamic>;
          lastPage = _parseLastPage(body['last_page']);
        }

        final newItems = raw
            .map((e) =>
                Map<String, dynamic>.from(e as Map<dynamic, dynamic>))
            .toList();

        if (mounted) {
          setState(() {
            _reservations.addAll(newItems);
            _reservationsHasMore = _reservationsPage < lastPage;
            _reservationsPage++;
            _reservationsLoading = false;
            _reservationsInitialLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _reservationsHasMore = false;
            _reservationsLoading = false;
            _reservationsInitialLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _reservationsHasMore = false;
          _reservationsLoading = false;
          _reservationsInitialLoading = false;
        });
      }
    }
  }

  Future<void> _loadLogsPage() async {
    if (_logsLoading || !_logsHasMore) return;
    setState(() => _logsLoading = true);

    try {
      final config = context.read<ExternalApplicationsConfigCubit>().state;
      if (config == null || config.apiHamamspaUrl.isEmpty) {
        if (mounted) {
          setState(() {
            _logsHasMore = false;
            _logsLoading = false;
            _logsInitialLoading = false;
          });
        }
        return;
      }

      final url = ApiHamamSpaUrlConstants.getMyPackageLogsUrl(
        config.apiHamamspaUrl,
        widget.packageId,
        page: _logsPage,
        itemsPerPage: _itemsPerPage,
      );
      final result = await RequestUtil.getJson(url);

      if (result.isSuccess && result.body is Map<String, dynamic>) {
        final data = result.body as Map<String, dynamic>;
        final raw = data['logs'] as List<dynamic>? ?? [];
        final lastPage = _parseLastPage(data['last_page']);
        final newItems = raw
            .map((e) =>
                Map<String, dynamic>.from(e as Map<dynamic, dynamic>))
            .toList();

        if (mounted) {
          setState(() {
            _logs.addAll(newItems);
            _logsHasMore = _logsPage < lastPage;
            _logsPage++;
            _logsLoading = false;
            _logsInitialLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _logsHasMore = false;
            _logsLoading = false;
            _logsInitialLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _logsHasMore = false;
          _logsLoading = false;
          _logsInitialLoading = false;
        });
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd.MM.yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd.MM.yyyy HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

    return Scaffold(
      appBar: TopAppBarWidget(title: widget.packageName),
      body: Column(
        children: [
          _buildToggleButtons(theme, labels),
          Expanded(
            child: _selectedTab == 0
                ? _buildReservationsContent(theme, labels)
                : _buildLogsContent(theme, labels),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(tab: NavTab.home),
    );
  }

  Widget _buildToggleButtons(dynamic theme, AppLabels labels) {
    return Container(
      margin: const EdgeInsets.only(
          top: 10.0, bottom: 20.0, right: 20, left: 20),
      width: MediaQuery.sizeOf(context).width,
      height: 50,
      alignment: AlignmentDirectional.center,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTab = 0),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedTab == 0
                      ? theme.primaryColor
                      : theme.defaultWhiteColor,
                  border: Border.all(
                    color: _selectedTab == 1
                        ? theme.default900Color
                        : theme.panelScaffoldBackgroundColor,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                margin: const EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                alignment: Alignment.center,
                child: Text(
                  labels.lessonAttendance,
                  style: theme.textSmallSemiBold(
                    color: theme.default900Color,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTab = 1),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedTab == 1
                      ? theme.primaryColor
                      : theme.defaultWhiteColor,
                  border: Border.all(
                    color: _selectedTab == 0
                        ? theme.default900Color
                        : theme.panelScaffoldBackgroundColor,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels.transactionHistory,
                  style: theme.textSmallSemiBold(
                    color: theme.default900Color,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationsContent(dynamic theme, AppLabels labels) {
    if (_reservationsInitialLoading) {
      return const Center(child: LoadingIndicatorWidget());
    }

    if (_reservations.isEmpty) {
      return Center(
        child: NoDataTextWidget(text: labels.noReservations),
      );
    }

    return ListView.builder(
      controller: _reservationsScrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount:
          _reservations.length + (_reservationsLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _reservations.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: LoadingIndicatorWidget(size: 28)),
          );
        }
        return _buildReservationCard(_reservations[index], theme, labels);
      },
    );
  }

  Widget _buildReservationCard(
      Map<String, dynamic> item, dynamic theme, AppLabels labels) {
    final int attendance =
        int.tryParse(item['attendance']?.toString() ?? '') ?? 0;

    Color attendanceColor;
    String attendanceText;
    IconData attendanceIcon;

    if (attendance == 1) {
      attendanceColor = theme.panelPaidColor;
      attendanceText = labels.attended;
      attendanceIcon = Icons.check_circle_outline;
    } else if (attendance == 2) {
      attendanceColor = theme.panelDebtColor;
      attendanceText = labels.burned;
      attendanceIcon = Icons.local_fire_department_outlined;
    } else {
      attendanceColor = theme.panelWarningColor;
      attendanceText = labels.notAttended;
      attendanceIcon = Icons.cancel_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
              children: [
                Expanded(
                  child: Text(
                    item['service_plan_name']?.toString() ?? '-',
                    style: theme.textBody(
                        color: theme.default900Color),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (attendanceColor as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(attendanceIcon, size: 18, color: attendanceColor),
                      const SizedBox(width: 6),
                      Text(
                        attendanceText,
                        style: theme.textSmallSemiBold(color: attendanceColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildReservationFieldLine(
              Icons.person_outline,
              labels.teacher,
              item['employee_name']?.toString() ?? '-',
              theme,
            ),
            const SizedBox(height: 6),
            _buildReservationFieldLine(
              Icons.room_outlined,
              labels.classroom,
              item['location_name']?.toString() ?? '-',
              theme,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildReservationField(Icons.calendar_today_outlined, labels.date,
                    _formatDate(item['plan_date']?.toString()), theme),
                const SizedBox(width: 16),
                _buildReservationField(Icons.access_time_outlined, labels.time,
                    item['plan_time']?.toString() ?? '-', theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Tek satır; değer sığmazsa sonunda …
  Widget _buildReservationFieldLine(
      IconData icon, String label, String value, dynamic theme) {
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

  Widget _buildReservationField(
      IconData icon, String label, String value, dynamic theme) {
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

  Widget _buildMiniInfo(
      IconData icon, String label, String value, dynamic theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: theme.defaultGray500Color),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: theme.textMini(color: theme.defaultGray500Color),
        ),
        Text(
          value,
          style: theme.textMini(color: theme.defaultGray700Color),
        ),
      ],
    );
  }

  Widget _buildLogsContent(dynamic theme, AppLabels labels) {
    if (_logsInitialLoading) {
      return const Center(child: LoadingIndicatorWidget());
    }

    if (_logs.isEmpty) {
      return Center(
        child: NoDataTextWidget(text: labels.noLogs),
      );
    }

    return ListView.builder(
      controller: _logsScrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _logs.length + (_logsLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _logs.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: LoadingIndicatorWidget(size: 28)),
          );
        }
        return _buildLogCard(_logs[index], theme, labels);
      },
    );
  }

  Widget _buildLogCard(
      Map<String, dynamic> item, dynamic theme, AppLabels labels) {
    final String action = item['action']?.toString() ?? '';
    final String actionLabel =
        labels.logActionLabels[action] ?? action;
    final int quantityChange =
        int.tryParse(item['quantity_change']?.toString() ?? '') ?? 0;
    final String remainAfter =
        item['remain_after']?.toString() ?? '-';
    final String note = item['note']?.toString() ?? '';

    final bool isNegative = quantityChange < 0;
    final Color changeColor =
        isNegative ? theme.panelDebtColor : theme.panelPaidColor;
    final String changeText =
        isNegative ? '$quantityChange' : '+$quantityChange';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
              children: [
                Expanded(
                  child: Text(
                    actionLabel,
                    style: theme.textCaptionSemiBold(
                        color: theme.default900Color),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (changeColor as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    changeText,
                    style: theme.textCaptionSemiBold(color: changeColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildMiniInfo(Icons.confirmation_number_outlined,
                    labels.remainAfter, remainAfter, theme),
                const Spacer(),
                Icon(Icons.access_time_outlined,
                    size: 12, color: theme.defaultGray500Color),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(item['created_at']?.toString()),
                  style: theme.textMini(color: theme.defaultGray500Color),
                ),
              ],
            ),
            if (note.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.notes_outlined,
                      size: 12, color: theme.defaultGray500Color),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      note,
                      style:
                          theme.textMini(color: theme.defaultGray700Color),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
