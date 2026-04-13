import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/constants/url/api_hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/member_home_reminders_service.dart';
import 'package:e_sport_life/core/services/member_today_payment_plan_stats_service.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentPlanListScreen extends StatefulWidget {
  const PaymentPlanListScreen({
    super.key,
    this.showTodayPaymentsOnly = false,
    this.showOverduePaymentsOnly = false,
    this.showNearDuePaymentsOnly = false,
  }) : assert(
          (showTodayPaymentsOnly ? 1 : 0) +
                  (showOverduePaymentsOnly ? 1 : 0) +
                  (showNearDuePaymentsOnly ? 1 : 0) <=
              1,
          'En fazla bir planlı ödeme listesi filtresi seçilebilir.',
        );

  /// `true`: yalnızca bugünün planlı ödemeleri; başlık [AppLabels.todayMyPayments].
  final bool showTodayPaymentsOnly;

  /// `true`: ödenmemiş ve vadesi bugünden önce; başlık [AppLabels.overduePaymentsListTitle].
  final bool showOverduePaymentsOnly;

  /// `true`: ödenmemiş, vade [bugün, bugün + [MemberHomeRemindersService.upcomingWindowDays]];
  /// başlık [AppLabels.nearDuePaymentsListTitle]. Hatırlatıcı ile aynı pencere.
  final bool showNearDuePaymentsOnly;

  @override
  State<PaymentPlanListScreen> createState() => _PaymentPlanListScreenState();
}

class _PaymentPlanListScreenState extends State<PaymentPlanListScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _items = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (widget.showTodayPaymentsOnly) {
      _loadAllPagesTodayOnly();
    } else if (widget.showOverduePaymentsOnly) {
      _loadAllPagesOverdueOnly();
    } else if (widget.showNearDuePaymentsOnly) {
      _loadAllPagesNearDueOnly();
    } else {
      _loadPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.showTodayPaymentsOnly ||
        widget.showOverduePaymentsOnly ||
        widget.showNearDuePaymentsOnly) {
      return;
    }
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadPage();
    }
  }

  String get _appBarTitle {
    final labels = AppLabels.current;
    if (widget.showTodayPaymentsOnly) {
      return labels.todayMyPayments.replaceAll('\n', ' ');
    }
    if (widget.showOverduePaymentsOnly) {
      return labels.overduePaymentsListTitle;
    }
    if (widget.showNearDuePaymentsOnly) {
      return labels.nearDuePaymentsListTitle.replaceAll('\n', ' ');
    }
    return labels.scheduledPayments.replaceAll('\n', ' ');
  }

  /// Bugünkü ödemeler: tüm sayfaları dolaşıp yerelde filtreler (API tarih filtresi yok).
  Future<void> _loadAllPagesTodayOnly() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _items.clear();
    });

    try {
      final externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      if (externalConfig == null || externalConfig.apiHamamspaUrl.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _initialLoading = false;
            _hasMore = false;
          });
        }
        return;
      }

      final apiUrl = externalConfig.apiHamamspaUrl;
      var page = 1;
      var lastPage = 1;

      do {
        final url = ApiHamamSpaUrlConstants.getMyPaymentPlansUrl(
          apiUrl,
          page: page,
          itemsPerPage: 20,
        );
        final result = await RequestUtil.getJson(url);

        if (!result.isSuccess || result.body is! Map<String, dynamic>) {
          break;
        }

        final data = result.body as Map<String, dynamic>;
        final newItems = MemberTodayPaymentPlanStatsService.extractPageItems(data);
        lastPage = MemberTodayPaymentPlanStatsService.extractLastPage(data);

        for (final item in newItems) {
          final pd = MemberTodayPaymentPlanStatsService.paymentDateFromItem(item);
          if (MemberTodayPaymentPlanStatsService.isPaymentDateToday(pd)) {
            _items.add(item);
          }
        }

        page++;
      } while (page <= lastPage);
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isLoading = false;
        _initialLoading = false;
        _hasMore = false;
      });
    }
  }

  /// Geciken ödemeler: tüm sayfaları dolaşır ([paginationSafetyCap] ile sınırlı).
  Future<void> _loadAllPagesOverdueOnly() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _items.clear();
    });

    try {
      final externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      if (externalConfig == null || externalConfig.apiHamamspaUrl.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _initialLoading = false;
            _hasMore = false;
          });
        }
        return;
      }

      final apiUrl = externalConfig.apiHamamspaUrl;
      final now = DateTime.now();
      final startToday = DateTime(now.year, now.month, now.day);
      var page = 1;
      var lastPage = 1;

      do {
        final url = ApiHamamSpaUrlConstants.getMyPaymentPlansUrl(
          apiUrl,
          page: page,
          itemsPerPage: 20,
        );
        final result = await RequestUtil.getJson(url);

        if (!result.isSuccess || result.body is! Map<String, dynamic>) {
          break;
        }

        final data = result.body as Map<String, dynamic>;
        final newItems =
            MemberTodayPaymentPlanStatsService.extractPageItems(data);
        lastPage = MemberTodayPaymentPlanStatsService.extractLastPage(data);

        for (final item in newItems) {
          if (MemberTodayPaymentPlanStatsService.parseIsPaid(item['is_paid'])) {
            continue;
          }
          final pd = MemberTodayPaymentPlanStatsService.paymentDateFromItem(item);
          if (pd.isEmpty) continue;
          try {
            final d = DateTime.parse(pd).toLocal();
            if (d.isBefore(startToday)) {
              _items.add(item);
            }
          } catch (_) {}
        }

        page++;
      } while (page <= lastPage &&
          page <= MemberTodayPaymentPlanStatsService.paginationSafetyCap);
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isLoading = false;
        _initialLoading = false;
        _hasMore = false;
      });
    }
  }

  /// Bugün + yakın vade: [MemberHomeRemindersService] ile aynı aralık (ödenmemiş).
  Future<void> _loadAllPagesNearDueOnly() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _items.clear();
    });

    try {
      final externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      if (externalConfig == null || externalConfig.apiHamamspaUrl.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _initialLoading = false;
            _hasMore = false;
          });
        }
        return;
      }

      final apiUrl = externalConfig.apiHamamspaUrl;
      final now = DateTime.now();
      final startToday = DateTime(now.year, now.month, now.day);
      final endInclusive = startToday.add(
        Duration(days: MemberHomeRemindersService.upcomingWindowDays),
      );
      var page = 1;
      var lastPage = 1;

      do {
        final url = ApiHamamSpaUrlConstants.getMyPaymentPlansUrl(
          apiUrl,
          page: page,
          itemsPerPage: 20,
        );
        final result = await RequestUtil.getJson(url);

        if (!result.isSuccess || result.body is! Map<String, dynamic>) {
          break;
        }

        final data = result.body as Map<String, dynamic>;
        final newItems =
            MemberTodayPaymentPlanStatsService.extractPageItems(data);
        lastPage = MemberTodayPaymentPlanStatsService.extractLastPage(data);

        for (final item in newItems) {
          if (MemberTodayPaymentPlanStatsService.parseIsPaid(item['is_paid'])) {
            continue;
          }
          final pd =
              MemberTodayPaymentPlanStatsService.paymentDateFromItem(item);
          if (pd.isEmpty) continue;
          try {
            final d = DateTime.parse(pd).toLocal();
            final day = DateTime(d.year, d.month, d.day);
            if (day.isBefore(startToday)) continue;
            if (day.isAfter(endInclusive)) continue;
            _items.add(item);
          } catch (_) {}
        }

        page++;
      } while (page <= lastPage &&
          page <= MemberTodayPaymentPlanStatsService.paginationSafetyCap);

      _items.sort((a, b) {
        final sa = MemberTodayPaymentPlanStatsService.paymentDateFromItem(a);
        final sb = MemberTodayPaymentPlanStatsService.paymentDateFromItem(b);
        try {
          return DateTime.parse(sa).compareTo(DateTime.parse(sb));
        } catch (_) {
          return 0;
        }
      });
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isLoading = false;
        _initialLoading = false;
        _hasMore = false;
      });
    }
  }

  Future<void> _loadPage() async {
    if (widget.showTodayPaymentsOnly ||
        widget.showOverduePaymentsOnly ||
        widget.showNearDuePaymentsOnly) {
      return;
    }
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      final externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      if (externalConfig == null) return;
      final apiUrl = externalConfig.apiHamamspaUrl;
      if (apiUrl.isEmpty) return;

      final url = ApiHamamSpaUrlConstants.getMyPaymentPlansUrl(
        apiUrl,
        page: _currentPage,
        itemsPerPage: 20,
      );
      final result = await RequestUtil.getJson(url);

      if (result.isSuccess && result.body is Map<String, dynamic>) {
        final data = result.body as Map<String, dynamic>;
        final newItems =
            MemberTodayPaymentPlanStatsService.extractPageItems(data);
        final lastPage = MemberTodayPaymentPlanStatsService.extractLastPage(data);

        setState(() {
          _items.addAll(newItems);
          _hasMore = _currentPage < lastPage;
          _currentPage++;
        });
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isLoading = false;
        _initialLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBarWidget(title: _appBarTitle),
      body: _initialLoading
          ? const Center(child: LoadingIndicatorWidget())
          : _items.isEmpty
              ? const Center(child: NoDataTextWidget())
              : _buildList(),
      bottomNavigationBar: BottomNavigationBarWidget(tab: NavTab.home),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      itemCount: _items.length +
          (_isLoading &&
                  !widget.showTodayPaymentsOnly &&
                  !widget.showOverduePaymentsOnly &&
                  !widget.showNearDuePaymentsOnly
              ? 1
              : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: LoadingIndicatorWidget(size: 28)),
          );
        }
        return _buildPaymentCard(_items[index]);
      },
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> item) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

    final paymentDate =
        MemberTodayPaymentPlanStatsService.paymentDateFromItem(item);
    final rawPrice = item['payment_price'] ?? item['amount'];
    final price = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice?.toString() ?? '') ?? 0;
    final explanation =
        (item['explanation'] ?? item['description'] ?? '').toString();
    final isPaid = MemberTodayPaymentPlanStatsService.parseIsPaid(item['is_paid']);

    final now = DateTime.now();
    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(paymentDate);
    } catch (_) {}

    final isOverdue = !isPaid &&
        parsedDate != null &&
        parsedDate.isBefore(DateTime(now.year, now.month, now.day));

    Color statusColor;
    String statusText;
    if (isPaid) {
      statusColor = theme.panelPaidColor;
      statusText = labels.paidStatus;
    } else if (isOverdue) {
      statusColor = theme.panelDebtColor;
      statusText = labels.overdueStatus;
    } else {
      statusColor = theme.panelWarningColor;
      statusText = labels.unpaidStatus;
    }

    final formattedDate = _formatDate(paymentDate);

    return Container(
      decoration: BoxDecoration(
        color: theme.defaultGray100Color,
        border: Border.all(color: theme.defaultGray200Color),
        borderRadius: BorderRadius.all(Radius.circular(theme.panelCardRadius)),
      ),
      margin: const EdgeInsetsDirectional.fromSTEB(20, 5, 20, 5),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labels.amount,
                        style: theme.textMini(color: theme.defaultGray500Color),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${price.toStringAsFixed(2)}${AppLabels.current.currencySuffix}',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textBodyBold(
                            color: theme.default900Color),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        labels.dueDate,
                        style: theme.textMini(color: theme.defaultGray500Color),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formattedDate,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textCaption(
                            color: theme.default900Color),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        labels.statusLabel,
                        style: theme.textMini(color: theme.defaultGray500Color),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusText,
                          style: theme.textMini(color: statusColor),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (explanation.isNotEmpty)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.defaultWhiteColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(theme.panelCardRadius),
                  bottomRight: Radius.circular(theme.panelCardRadius),
                ),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildInfoRow(
                icon: Icons.notes_outlined,
                text: explanation,
                color: theme.defaultGray500Color,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: BlocTheme.theme.textCaption(color: color),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
