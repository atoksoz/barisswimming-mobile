import 'package:e_sport_life/screen/virtual-wallet-screen/wallet_logs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../config/external-applications-config/external_applications_config_cubit.dart';
import '../../config/themes/bloc_theme.dart';
import '../../config/user-config/user_config_cubit.dart';
import '../../core/services/jwt_storage_service.dart';
import '../../core/services/wallet_service.dart';
import '../../core/widgets/bottom_navigation_bar_widget.dart';
import '../../core/widgets/loading_indicator_widget.dart';
import '../../core/widgets/no_data_text_widget.dart';
import '../../core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/screen/panel/member/qr-code/member_fixed_qr_screen.dart';

class VirtualWalletScreen extends StatefulWidget {
  const VirtualWalletScreen({Key? key}) : super(key: key);

  static const String id = "Sanal Cüzdan";

  @override
  State<VirtualWalletScreen> createState() => _VirtualWalletScreenState();
}

class _VirtualWalletScreenState extends State<VirtualWalletScreen> {
  double _balance = 0;
  List<dynamic> _logs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final token = await JwtStorageService.getToken();

      if (externalConfig != null && token != null) {
        final kantincimUrl = externalConfig.kantincim;

        // Fetch balance
        final balance = await WalletService.getBalance(
          kantincimUrl: kantincimUrl,
          token: token,
        );

        // Fetch first page of logs (summary)
        final logsData = await WalletService.getLogs(
          kantincimUrl: kantincimUrl,
          token: token,
          page: 1,
        );

        setState(() {
          if (balance != null) _balance = balance;
          if (logsData != null) {
            _logs = logsData['data'] ?? [];
          }
        });
      }
    } catch (e) {
      print('Error fetching initial wallet data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleShowAll() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WalletLogsScreen(),
      ),
    );
  }

  Widget _buildWalletHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bakiye Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: BlocTheme.theme.defaultGray50Color,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Bakiye",
                style: TextStyle(
                  fontSize: 20,
                  color: BlocTheme.theme.defaultGray500Color,
                  fontFamily: "Inter",
                ),
              ),
              Text(
                NumberFormat.currency(
                        locale: 'tr_TR', symbol: '₺', decimalDigits: 2)
                    .format(_balance),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: BlocTheme.theme.orderSummaryColor,
                  fontFamily: "Inter",
                ),
              ),
            ],
          ),
        ),
        if (_balance > 0) ...[
          const SizedBox(height: 20),
          // Ödeme Yap Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                final userConfig = context.read<UserConfigCubit>().state;
                if (userConfig != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MemberFixedQrScreen(
                        value: userConfig.memberId,
                        infoText:
                            "Harcamalarınızı bakiyeden ödemek için QR kodu okutunuz ya da QR kodun altında yazan numarayı görevliye söyleyiniz.",
                        topText:
                            "Bakiye: ${NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 2).format(_balance)}",
                      ),
                    ),
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                side:
                    BorderSide(color: BlocTheme.theme.default600Color, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Ödeme Yap",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: BlocTheme.theme.default900Color,
                  fontFamily: "Inter",
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  DateTime _parseDate(String dateStr) {
    try {
      return DateFormat("dd.MM.yyyy HH:mm").parse(dateStr);
    } catch (_) {
      try {
        return DateTime.parse(dateStr);
      } catch (_) {
        return DateTime.now();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBarWidget(title: "Sanal Cüzdan"),
      body: _isLoading && _logs.isEmpty
          ? const Center(child: LoadingIndicatorWidget())
          : _logs.isEmpty
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: _buildWalletHeader(),
                    ),
                    const Expanded(
                      child: Center(
                        child: NoDataTextWidget(),
                      ),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWalletHeader(),
                        const SizedBox(height: 30),
                        // Header
                        Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Geçmiş İşlemler",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: BlocTheme.theme.default900Color,
                            fontFamily: "Inter",
                          ),
                        ),
                        if (_logs.isNotEmpty)
                          GestureDetector(
                            onTap: _handleShowAll,
                            child: Row(
                              children: [
                                Text(
                                  "Tüm Liste",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: BlocTheme.theme.default900Color,
                                    fontFamily: "Inter",
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 16,
                                  color: BlocTheme.theme.default900Color,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    if (_logs.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: NoDataTextWidget(),
                        ),
                      )
                    else
                      // Transactions List
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _logs.length > 5 ? 5 : _logs.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 15),
                        itemBuilder: (context, index) {
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                                  color: BlocTheme
                                                      .theme.defaultBlackColor,
                                                  fontFamily: "Inter",
                                                ),
                                              ),
                                              TextSpan(
                                                text: log["order_name"] ??
                                                    log["type_text"] ??
                                                    "-",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: BlocTheme
                                                      .theme.defaultBlackColor,
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
                                        color:
                                            BlocTheme.theme.defaultGray500Color,
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
                                            color: BlocTheme
                                                .theme.defaultGray500Color,
                                            fontFamily: "Inter",
                                          ),
                                        ),
                                        TextSpan(
                                          text: log["description"] ?? "-",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: BlocTheme
                                                .theme.defaultBlackColor,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                              color: BlocTheme
                                                  .theme.defaultGray500Color,
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
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: BlocTheme
                                                  .theme.defaultBlackColor,
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
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBarWidget(tab: NavTab.home),
    );
  }
}
