import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/constants/url/api_hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/member_today_payment_plan_stats_service.dart';
import 'package:e_sport_life/core/utils/member_package_near_expiry_util.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/screen/panel/member/muzik-okulum/package_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class PackageListScreen extends StatefulWidget {
  const PackageListScreen({
    super.key,
    this.activeOnly = false,
    this.nearExpiryOnly = false,
  }) : assert(
          !nearExpiryOnly || !activeOnly,
          'nearExpiryOnly ile activeOnly birlikte kullanılmaz.',
        );

  /// true: yalnızca bitiş tarihi bugün ve sonrası olan paketler; başlık [AppLabels.activePackagesListTitle].
  final bool activeOnly;

  /// true: tüm sayfalar taranır; yalnızca yakında bitecek aktif paketler; başlık [AppLabels.nearExpiryPackagesListTitle].
  final bool nearExpiryOnly;

  @override
  State<PackageListScreen> createState() => _PackageListScreenState();
}

class _PackageListScreenState extends State<PackageListScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _items = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    if (!widget.nearExpiryOnly) {
      _scrollController.addListener(_onScroll);
      _loadPage();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadAllNearExpiryPages();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.nearExpiryOnly) return;
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadPage();
    }
  }

  Future<void> _loadAllNearExpiryPages() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _items.clear();
    });

    try {
      final config = context.read<ExternalApplicationsConfigCubit>().state;
      if (config == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _initialLoading = false;
            _hasMore = false;
          });
        }
        return;
      }
      final apiUrl = config.apiHamamspaUrl;
      if (apiUrl.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _initialLoading = false;
            _hasMore = false;
          });
        }
        return;
      }

      var page = 1;
      var lastPage = 1;
      do {
        final url = ApiHamamSpaUrlConstants.getMyPackagesUrl(
          apiUrl,
          page: page,
          itemsPerPage: 20,
        );
        final result = await RequestUtil.getJson(url);
        if (!result.isSuccess || result.body is! Map<String, dynamic>) {
          break;
        }
        final body = result.body as Map<String, dynamic>;
        final newItems =
            MemberTodayPaymentPlanStatsService.extractPageItems(body);
        lastPage = MemberTodayPaymentPlanStatsService.extractLastPage(body);
        for (final m in newItems) {
          if (MemberPackageNearExpiryUtil.isNearExpiry(m)) {
            _items.add(Map<String, dynamic>.from(m));
          }
        }
        page++;
      } while (page <= lastPage &&
          page <= MemberTodayPaymentPlanStatsService.paginationSafetyCap);

      _items.sort((a, b) {
        final da = MemberPackageNearExpiryUtil.calendarDaysUntilEnd(a);
        final db = MemberPackageNearExpiryUtil.calendarDaysUntilEnd(b);
        if (da != null && db != null && da != db) return da.compareTo(db);
        if (da != null && db == null) return -1;
        if (da == null && db != null) return 1;
        return MemberPackageNearExpiryUtil.pickRemain(a) -
            MemberPackageNearExpiryUtil.pickRemain(b);
      });
    } catch (e) {
      debugPrint('PackageListScreen near-expiry load error: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _initialLoading = false;
        _hasMore = false;
      });
    }
  }

  Future<void> _loadPage() async {
    if (widget.nearExpiryOnly) return;
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final config =
          context.read<ExternalApplicationsConfigCubit>().state;
      if (config == null) return;
      final apiUrl = config.apiHamamspaUrl;
      if (apiUrl.isEmpty) return;

      final url = ApiHamamSpaUrlConstants.getMyPackagesUrl(
        apiUrl,
        page: _currentPage,
      );

      final result = await RequestUtil.getJson(url);
      if (result.body is Map<String, dynamic>) {
        final data = result.body as Map<String, dynamic>;
        final List items = data['data'] ?? [];
        final int lastPage = data['last_page'] ?? 1;

        final toAdd = <Map<String, dynamic>>[];
        for (final e in items) {
          if (e is! Map) continue;
          final m = Map<String, dynamic>.from(e);
          if (widget.activeOnly && !_isActive(m)) continue;
          if (widget.activeOnly &&
              MemberPackageNearExpiryUtil.shouldOmitFromActivePackagesList(m)) {
            continue;
          }
          toAdd.add(m);
        }

        setState(() {
          _items.addAll(toAdd);
          _hasMore = _currentPage < lastPage;
          _currentPage++;
          _initialLoading = false;
          _isLoading = false;
        });

        if (widget.activeOnly &&
            _items.isEmpty &&
            _hasMore &&
            mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _loadPage();
          });
        }
      } else {
        setState(() {
          _initialLoading = false;
          _isLoading = false;
          _hasMore = false;
        });
      }
    } catch (e) {
      debugPrint('PackageListScreen load error: $e');
      setState(() {
        _initialLoading = false;
        _isLoading = false;
      });
    }
  }

  /// Bitiş günü yerel takvimde bugün veya sonrası (özet / API ile uyumlu).
  bool _isActive(Map<String, dynamic> item) {
    final endDateStr = item['end_date']?.toString();
    if (endDateStr == null || endDateStr.isEmpty) return false;
    try {
      final endDate = DateTime.parse(endDateStr).toLocal();
      final now = DateTime.now();
      final startToday = DateTime(now.year, now.month, now.day);
      return !endDate.isBefore(startToday);
    } catch (_) {
      return false;
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

  String _formatCurrency(dynamic value) {
    final num = double.tryParse(value?.toString() ?? '') ?? 0;
    return '${num.toStringAsFixed(2)}${AppLabels.current.currencySuffix}';
  }

  String _getPackageName(Map<String, dynamic> item) {
    String name = item['member_type']?.toString() ?? '';
    if (name.isEmpty) {
      final pp = item['product_package'];
      if (pp is Map<String, dynamic>) {
        name = pp['description'] ?? '';
      }
    }
    final parenIndex = name.indexOf('(');
    if (parenIndex > 0) {
      name = name.substring(0, parenIndex).trim();
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

    final appBarTitle = widget.nearExpiryOnly
        ? labels.nearExpiryPackagesListTitle
        : widget.activeOnly
            ? labels.activePackagesListTitle
            : labels.packageInfo.replaceAll('\n', ' ');

    return Scaffold(
      appBar: TopAppBarWidget(title: appBarTitle),
      body: _initialLoading
          ? const Center(child: LoadingIndicatorWidget())
          : _items.isEmpty
              ? const Center(child: NoDataTextWidget())
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  itemCount: _items.length +
                      (!widget.nearExpiryOnly && _hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _items.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: LoadingIndicatorWidget()),
                      );
                    }
                    return _buildPackageCard(_items[index], theme, labels);
                  },
                ),
      bottomNavigationBar: BottomNavigationBarWidget(tab: NavTab.home),
    );
  }

  Widget _buildPackageCard(
      Map<String, dynamic> item, dynamic theme, AppLabels labels) {
    final bool active = _isActive(item);
    final String name = _getPackageName(item);
    final int quantity = int.tryParse(item['quantity']?.toString() ?? '') ?? 0;
    final int remainQuantity =
        int.tryParse(item['remain_quantity']?.toString() ?? '') ?? 0;
    final double grossPrice =
        double.tryParse(item['price']?.toString() ?? '') ?? 0;
    final double discount =
        double.tryParse(item['discount']?.toString() ?? '') ?? 0;
    final double netPrice =
        double.tryParse(item['subscription_price']?.toString() ?? '') ?? 0;
    final bool expired = !active || (quantity > 0 && remainQuantity <= 0);
    final TextDecoration textDeco =
        expired ? TextDecoration.lineThrough : TextDecoration.none;

    final int packageId =
        int.tryParse(item['id']?.toString() ?? '') ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PackageDetailScreen(
              packageId: packageId,
              packageName: name,
            ),
          ),
        );
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.defaultWhiteColor,
        border: Border.all(color: theme.defaultGray200Color),
        borderRadius: BorderRadius.circular(theme.panelCardRadius),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.defaultGray100Color,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(theme.panelCardRadius),
                topRight: Radius.circular(theme.panelCardRadius),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: theme.textBodyBold(
                      color: expired
                          ? theme.defaultGray500Color
                          : theme.default900Color,
                    ).copyWith(decoration: textDeco),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(active, theme, labels),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_outlined,
                  color: theme.default900Color,
                  size: 28,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.calendar_today_outlined,
                        labels.startDate,
                        _formatDate(item['start_date']?.toString()),
                        theme,
                        strikeThrough: expired,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.event_outlined,
                        labels.endDate,
                        _formatDate(item['end_date']?.toString()),
                        theme,
                        strikeThrough: expired,
                      ),
                    ),
                  ],
                ),
                if (quantity > 0) ...[
                  const SizedBox(height: 10),
                  _buildInfoItem(
                    Icons.confirmation_number_outlined,
                    labels.remainingRights,
                    '$remainQuantity / $quantity',
                    theme,
                    valueColor: theme.default900Color,
                    strikeThrough: expired,
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.defaultGray100Color,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(theme.panelCardRadius),
                bottomRight: Radius.circular(theme.panelCardRadius),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labels.packagePrice,
                        style: theme.textMini(
                            color: theme.defaultGray500Color),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatCurrency(grossPrice),
                        style: theme.textCaptionSemiBold(
                          color: expired
                              ? theme.defaultGray500Color
                              : theme.defaultGray700Color,
                        ).copyWith(decoration: textDeco),
                      ),
                      if (discount > 0) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (theme.panelWarningColor as Color)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${labels.discountLabel}: -${_formatCurrency(discount)}',
                            style: theme.textMini(
                                color: theme.panelWarningColor),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      labels.netPrice,
                      style: theme.textMini(
                          color: theme.defaultGray500Color),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatCurrency(netPrice),
                      style: theme.textBodyBold(
                        color: expired
                            ? theme.defaultGray500Color
                            : theme.default900Color,
                      ).copyWith(decoration: textDeco),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildStatusBadge(bool active, dynamic theme, AppLabels labels) {
    final Color color =
        active ? theme.panelPaidColor : theme.defaultGray500Color;
    final String text =
        active ? labels.activeStatus : labels.expiredStatus;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: theme.textMini(color: color),
      ),
    );
  }

  Widget _buildInfoItem(
      IconData icon, String label, String value, dynamic theme,
      {Color? valueColor, bool strikeThrough = false}) {
    final Color effectiveColor = strikeThrough
        ? theme.defaultGray500Color
        : (valueColor ?? theme.defaultGray700Color);
    final TextDecoration deco =
        strikeThrough ? TextDecoration.lineThrough : TextDecoration.none;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: theme.defaultGray500Color),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textMini(color: theme.defaultGray500Color),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme
                    .textCaptionSemiBold(color: effectiveColor)
                    .copyWith(decoration: deco),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
