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

class StatementListScreen extends StatefulWidget {
  const StatementListScreen({Key? key}) : super(key: key);

  @override
  State<StatementListScreen> createState() => _StatementListScreenState();
}

class _StatementListScreenState extends State<StatementListScreen> {
  late Future<List<Map<String, dynamic>>> _statementsFuture;

  @override
  void initState() {
    super.initState();
    _statementsFuture = _fetchStatements();
  }

  Future<List<Map<String, dynamic>>> _fetchStatements() async {
    try {
      final externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      if (externalConfig == null) return [];
      final apiUrl = externalConfig.apiHamamspaUrl;
      if (apiUrl.isEmpty) return [];

      final url = ApiHamamSpaUrlConstants.getMyStatementsUrl(apiUrl);
      final result = await RequestUtil.getJson(url);

      if (result.isSuccess && result.output is List) {
        return List<Map<String, dynamic>>.from(
          (result.output as List).map((e) => Map<String, dynamic>.from(e)),
        );
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = AppLabels.current;

    return Scaffold(
      appBar: TopAppBarWidget(
          title: labels.financialStatement.replaceAll('\n', ' ')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _statementsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicatorWidget());
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return _buildList(snapshot.data!);
          } else {
            return const Center(child: NoDataTextWidget());
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBarWidget(tab: NavTab.home),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

    double totalBalance = 0;
    for (final item in items) {
      if (item['type'] == 'sale') {
        totalBalance += (item['subscription_price'] ?? 0).toDouble();
      } else {
        totalBalance -= (item['paid_amount'] ?? 0).toDouble();
      }
    }

    return Column(
      children: [
        _buildBalanceSummary(theme, labels, totalBalance),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 5, bottom: 20),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              if (item['type'] == 'sale') {
                return _buildSaleCard(item, theme, labels);
              } else {
                return _buildPaymentCard(item, theme, labels);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceSummary(dynamic theme, AppLabels labels, double balance) {
    final Color frame = theme.default900Color;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: frame.withValues(alpha: 0.06),
        border: Border.all(color: frame.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            labels.balance,
            style: theme.textBodyBold(color: theme.default900Color),
          ),
          Text(
            _formatCurrency(balance.abs()),
            style: theme.textBodyBold(color: theme.default900Color),
          ),
        ],
      ),
    );
  }

  /// Satış kartı — Paket Adı, Paket Ücreti, İndirim, Net Tutar, Kayıt Tarihi
  Widget _buildSaleCard(
      Map<String, dynamic> item, dynamic theme, AppLabels labels) {
    final packageName = (item['package_name'] ?? '-').toString();
    final price = (item['price'] ?? 0).toDouble();
    final discount = (item['discount'] ?? 0).toDouble();
    final subscriptionPrice = (item['subscription_price'] ?? 0).toDouble();
    final registerDate = (item['register_date'] ?? '').toString();

    return Container(
      decoration: BoxDecoration(
        color: theme.defaultGray100Color,
        border: Border.all(color: theme.defaultGray200Color),
        borderRadius:
            BorderRadius.all(Radius.circular(theme.panelCardRadius)),
      ),
      margin: const EdgeInsetsDirectional.fromSTEB(20, 5, 20, 5),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        packageName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: theme.textBodyBold(
                            color: theme.default900Color),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildChip(labels.saleLabel, theme.panelDebtColor),
                          const SizedBox(width: 8),
                          if (registerDate.isNotEmpty)
                            Text(
                              _formatDate(registerDate),
                              style: theme.textCaption(
                                  color: theme.defaultGray500Color),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.defaultWhiteColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(theme.panelCardRadius),
                bottomRight: Radius.circular(theme.panelCardRadius),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _buildDetailRow(
                  labels.packagePrice,
                  _formatCurrency(price),
                  theme,
                ),
                if (discount > 0) ...[
                  const SizedBox(height: 4),
                  _buildDetailRow(
                    labels.discount,
                    '-${_formatCurrency(discount)}',
                    theme,
                    valueColor: theme.panelPaidColor,
                  ),
                ],
                const SizedBox(height: 4),
                Divider(height: 1, color: theme.defaultGray200Color),
                const SizedBox(height: 4),
                _buildDetailRow(
                  labels.netPrice,
                  _formatCurrency(subscriptionPrice),
                  theme,
                  isBold: true,
                  valueColor: theme.panelDebtColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tahsilat kartı — Ödeme etiketi, Ödenen Tutar, Ödeme Türü, Açıklama, Tarih
  Widget _buildPaymentCard(
      Map<String, dynamic> item, dynamic theme, AppLabels labels) {
    final paidAmount = (item['paid_amount'] ?? 0).toDouble();
    final explanation = (item['explanation'] ?? '').toString();
    final paymentDate = (item['payment_date'] ?? '').toString();
    final paymentType = (item['payment_type'] ?? '').toString();

    return Container(
      decoration: BoxDecoration(
        color: theme.defaultGray100Color,
        border: Border.all(color: theme.defaultGray200Color),
        borderRadius:
            BorderRadius.all(Radius.circular(theme.panelCardRadius)),
      ),
      margin: const EdgeInsetsDirectional.fromSTEB(20, 5, 20, 5),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildChip(
                        labels.collectionLabel, theme.panelPaidColor),
                    const Spacer(),
                    Text(
                      _formatCurrency(paidAmount),
                      style: theme.textBodyBold(color: theme.panelPaidColor),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (paymentDate.isNotEmpty)
                      Expanded(
                        child: Text(
                          _formatDate(paymentDate),
                          style: theme.textCaption(
                              color: theme.defaultGray500Color),
                        ),
                      ),
                    if (paymentType.isNotEmpty)
                      _buildChip(paymentType, theme.defaultBlue500Color),
                  ],
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(Icons.notes_outlined,
                        size: 14, color: theme.defaultGray500Color),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      explanation,
                      style: theme.textCaption(
                          color: theme.defaultGray500Color),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChip(String text, Color color) {
    final theme = BlocTheme.theme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: theme.textMini(color: color),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    dynamic theme, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textCaption(color: theme.defaultGray500Color),
        ),
        Text(
          value,
          style: isBold
              ? theme.textBodyBold(
                  color: valueColor ?? theme.defaultGray700Color)
              : theme.textCaption(
                  color: valueColor ?? theme.defaultGray700Color),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)}${AppLabels.current.currencySuffix}';
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
