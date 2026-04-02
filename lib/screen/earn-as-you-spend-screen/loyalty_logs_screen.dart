import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../config/external-applications-config/external_applications_config_cubit.dart';
import '../../config/themes/bloc_theme.dart';
import '../../core/services/jwt_storage_service.dart';
import '../../core/services/loyalty_service.dart';
import '../../core/widgets/bottom_navigation_bar_widget.dart';
import '../../core/widgets/loading_indicator_widget.dart';
import '../../core/widgets/no_data_text_widget.dart';
import '../../core/widgets/top_appbar_widget.dart';

class LoyaltyLogsScreen extends StatefulWidget {
  const LoyaltyLogsScreen({Key? key}) : super(key: key);

  static const String id = "İşlem Geçmişi";

  @override
  State<LoyaltyLogsScreen> createState() => _LoyaltyLogsScreenState();
}

class _LoyaltyLogsScreenState extends State<LoyaltyLogsScreen> {
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
        final logsData = await LoyaltyService.getLogs(
          kantincimUrl: externalConfig.kantincim,
          token: token,
          page: _currentPage,
        );

        if (logsData != null) {
          final newLogs = logsData['data'] ?? [];
          setState(() {
            if (newLogs.isNotEmpty) {
              _logs.addAll(newLogs);
              _currentPage++;
            }

            // Daha fazla veri olup olmadığını kontrol et (farklı API formatları için esnek kontrol)
            final lastPage = logsData['last_page'];
            final total = logsData['total'];
            final nextPageUrl = logsData['next_page_url'];

            if (nextPageUrl != null) {
              _hasMore = true;
            } else if (lastPage != null) {
              _hasMore = _currentPage <= lastPage;
            } else if (total != null) {
              _hasMore = _logs.length < total;
            } else {
              // Eğer hiçbiri yoksa ve gelen veri boşsa veya sayfa başı veriden (örn: 10-15) azsa son sayfadayızdır
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
      print('Error fetching loyalty logs: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                return Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: BlocTheme.theme.defaultGray50Color,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log["description"] ?? "İşlem",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: BlocTheme.theme.defaultBlackColor,
                          fontFamily: "Inter",
                        ),
                      ),
                      const SizedBox(height: 10),
                      Divider(
                        height: 1,
                        color: BlocTheme.theme.defaultGray100Color,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            log["created_at"] != null
                                ? DateFormat('dd/MM/yyyy').format(
                                    DateTime.parse(log["created_at"]))
                                : "",
                            style: TextStyle(
                              fontSize: 14,
                              color: BlocTheme.theme.defaultGray500Color,
                              fontFamily: "Inter",
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Kazanılan Puan : ",
                                  style: TextStyle(
                                    fontSize: 14,
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
                                              (log["amount"] ?? 0)
                                                  .toString()) ??
                                          0),
                                  style: TextStyle(
                                    fontSize: 14,
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
