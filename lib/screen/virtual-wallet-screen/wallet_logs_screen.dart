import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../config/external-applications-config/external_applications_config_cubit.dart';
import '../../config/themes/bloc_theme.dart';
import '../../core/services/jwt_storage_service.dart';
import '../../core/services/wallet_service.dart';
import '../../core/widgets/bottom_navigation_bar_widget.dart';
import '../../core/widgets/loading_indicator_widget.dart';
import '../../core/widgets/no_data_text_widget.dart';
import '../../core/widgets/top_appbar_widget.dart';

class WalletLogsScreen extends StatefulWidget {
  const WalletLogsScreen({Key? key}) : super(key: key);

  static const String id = "İşlem Geçmişi";

  @override
  State<WalletLogsScreen> createState() => _WalletLogsScreenState();
}

class _WalletLogsScreenState extends State<WalletLogsScreen> {
  List<dynamic> _logs = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchLogs();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 500 &&
        !_isLoading &&
        _hasMore) {
      _fetchLogs();
    }
  }

  Future<void> _fetchLogs() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final token = await JwtStorageService.getToken();

      if (externalConfig != null && token != null) {
        final logsData = await WalletService.getLogs(
          kantincimUrl: externalConfig.kantincim,
          token: token,
          page: _currentPage,
        );

        if (logsData != null) {
          final newLogs = logsData['data'] ?? [];
          final pagination = logsData['pagination'];
          
          setState(() {
            if (newLogs.isNotEmpty) {
              _logs.addAll(newLogs);
              _currentPage++;
            }

            final lastPage = pagination != null ? pagination['last_page'] : null;
            final total = pagination != null ? pagination['total'] : null;
            final nextPageUrl = pagination != null ? pagination['next_page_url'] : null;

            if (nextPageUrl != null) {
              _hasMore = true;
            } else if (lastPage != null) {
              _hasMore = _currentPage <= lastPage;
            } else if (total != null) {
              _hasMore = _logs.length < total;
            } else {
              _hasMore = newLogs.isNotEmpty && newLogs.length >= 10;
            }
          });
        } else {
          setState(() {
            _hasMore = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching wallet logs: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  DateTime _parseDate(String dateStr) {
    try {
      // API formatı: "dd.MM.yyyy HH:mm"
      return DateFormat("dd.MM.yyyy HH:mm").parse(dateStr);
    } catch (_) {
      try {
        // Yedek format: ISO 8601
        return DateTime.parse(dateStr);
      } catch (_) {
        return DateTime.now();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBarWidget(title: "İşlem Geçmişi"),
      body: _isLoading && _logs.isEmpty
          ? const Center(child: LoadingIndicatorWidget())
          : _logs.isEmpty
              ? const Center(child: NoDataTextWidget())
              : ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
              itemCount: _logs.length + (_hasMore ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                if (index == _logs.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final log = _logs[index];
                Color statusColor = BlocTheme.theme.defaultBlackColor;
                final typeText = log["type_text"] ?? "";
                final isBalanceLoading = typeText == "Bakiye Yükleme";

                if (typeText == "Beklemede") {
                  statusColor = BlocTheme.theme.defaultOrange500Color;
                } else if (typeText == "İptal edildi" || typeText == "Harcama") {
                  statusColor = BlocTheme.theme.defaultRed700Color;
                } else if (isBalanceLoading) {
                  statusColor = BlocTheme.theme.default900Color;
                }

                return Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  if (!isBalanceLoading) ...[
                                    TextSpan(
                                      text: "Sipariş No : ",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: BlocTheme.theme.defaultBlackColor,
                                        fontFamily: "Inter",
                                      ),
                                    ),
                                    TextSpan(
                                      text: log["order_name"] ??
                                          log["type_text"] ??
                                          "-",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            BlocTheme.theme.defaultBlackColor,
                                        fontFamily: "Inter",
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            log["created_at"] != null
                                ? DateFormat('dd/MM/yyyy').format(
                                    _parseDate(log["created_at"]))
                                : "",
                            style: TextStyle(
                              fontSize: 14,
                              color: BlocTheme.theme.defaultGray500Color,
                              fontFamily: "Inter",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Divider(
                        height: 1,
                        color: BlocTheme.theme.defaultGray100Color,
                      ),
                      const SizedBox(height: 10),
                      if (!isBalanceLoading) ...[
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Açıklama : ",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: BlocTheme.theme.defaultGray500Color,
                                  fontFamily: "Inter",
                                ),
                              ),
                              TextSpan(
                                text: log["description"] ?? "-",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: BlocTheme.theme.defaultBlackColor,
                                  fontFamily: "Inter",
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (typeText == "Beklemede")
                                Icon(Icons.access_time,
                                    size: 16, color: statusColor),
                              const SizedBox(width: 5),
                              Text(
                                typeText,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                  fontFamily: "Inter",
                                ),
                              ),
                            ],
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Tutar : ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: BlocTheme.theme.defaultGray500Color,
                                    fontFamily: "Inter",
                                  ),
                                ),
                                TextSpan(
                                  text: NumberFormat.currency(
                                          locale: 'tr_TR',
                                          symbol: '₺',
                                          decimalDigits: 2)
                                      .format(double.tryParse(
                                              (log["amount"] ?? 0).toString()) ??
                                          0),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: BlocTheme.theme.defaultBlackColor,
                                    fontFamily: "Inter",
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
            ),
      bottomNavigationBar: BottomNavigationBarWidget(tab: NavTab.home),
    );
  }
}
