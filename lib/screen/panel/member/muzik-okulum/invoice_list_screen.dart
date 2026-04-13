import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/constants/url/api_hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/data/model/member_invoice_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({Key? key}) : super(key: key);

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  late Future<List<MemberInvoiceModel>> _invoicesFuture;

  @override
  void initState() {
    super.initState();
    _invoicesFuture = _fetchInvoices();
  }

  Future<List<MemberInvoiceModel>> _fetchInvoices() async {
    try {
      final externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      if (externalConfig == null) return [];
      final apiUrl = externalConfig.apiHamamspaUrl;
      if (apiUrl.isEmpty) return [];

      final url = ApiHamamSpaUrlConstants.getMyInvoicesUrl(apiUrl);
      final result = await RequestUtil.getJson(url);

      if (result.isSuccess && result.output is List) {
        return (result.output as List)
            .map((e) => MemberInvoiceModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ))
            .toList();
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
      appBar: TopAppBarWidget(title: labels.invoiceInfo.replaceAll('\n', ' ')),
      body: FutureBuilder<List<MemberInvoiceModel>>(
        future: _invoicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicatorWidget());
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return _buildInvoiceList(snapshot.data!);
          } else {
            return const Center(child: NoDataTextWidget());
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBarWidget(tab: NavTab.profile),
    );
  }

  Widget _buildInvoiceList(List<MemberInvoiceModel> invoices) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final inv = invoices[index];
        return _InvoiceCard(invoice: inv, theme: theme, labels: labels);
      },
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({
    required this.invoice,
    required this.theme,
    required this.labels,
  });

  final MemberInvoiceModel invoice;
  final BaseTheme theme;
  final AppLabels labels;

  String _recipientTypeLabel() {
    switch (invoice.recipientType) {
      case 'individual':
        return labels.invoiceRecipientTypeIndividual;
      case 'corporate':
        return labels.invoiceRecipientTypeCorporate;
      case 'sole_trader':
        return labels.invoiceRecipientTypeSoleTrader;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipientLabel = _recipientTypeLabel();
    final address = invoice.displayAddress;
    final hasVkn = invoice.vkn != null && invoice.vkn!.trim().isNotEmpty;
    final hasTckn = invoice.tckn != null && invoice.tckn!.trim().isNotEmpty;
    final hasTaxOffice =
        invoice.taxOffice != null && invoice.taxOffice!.trim().isNotEmpty;
    final hasEmail = invoice.email != null && invoice.email!.trim().isNotEmpty;
    final hasPhone = invoice.phone != null && invoice.phone!.trim().isNotEmpty;
    final hasNote = invoice.note != null && invoice.note!.trim().isNotEmpty;
    final hasCompanyTitle = invoice.companyTitle != null &&
        invoice.companyTitle!.trim().isNotEmpty;

    final subtitleParts = <String>[
      if (hasCompanyTitle) invoice.companyTitle!.trim(),
      if (recipientLabel.isNotEmpty) recipientLabel,
    ];
    final subtitle = subtitleParts.join(' · ');

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
          SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(16, 0, 10, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.displayName,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: theme.textBodyBold(
                              color: theme.default900Color),
                        ),
                        if (subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: theme.textCaption(
                                color: theme.defaultGray900Color),
                          ),
                      ],
                    ),
                  ),
                ),
                if (invoice.isDefault)
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.default100Color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          labels.invoiceDefaultBadge,
                          style:
                              theme.textMini(color: theme.default700Color),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Detail section
          if (hasVkn ||
              hasTckn ||
              hasTaxOffice ||
              hasEmail ||
              hasPhone ||
              address.isNotEmpty ||
              hasNote)
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
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasVkn)
                    _labeledRow(labels.invoiceVkn, invoice.vkn!.trim()),
                  if (hasTckn) ...[
                    if (hasVkn) const SizedBox(height: 8),
                    _labeledRow(labels.invoiceTckn, invoice.tckn!.trim()),
                  ],
                  if (hasTaxOffice) ...[
                    if (hasVkn || hasTckn) const SizedBox(height: 8),
                    _labeledRow(
                        labels.invoiceTaxOffice, invoice.taxOffice!.trim()),
                  ],
                  if (hasEmail) ...[
                    if (hasVkn || hasTckn || hasTaxOffice)
                      const SizedBox(height: 8),
                    _iconRow(Icons.mail_outline, invoice.email!.trim()),
                  ],
                  if (hasPhone) ...[
                    if (hasVkn || hasTckn || hasTaxOffice || hasEmail)
                      const SizedBox(height: 8),
                    _iconRow(Icons.phone_outlined, invoice.phone!.trim()),
                  ],
                  if (address.isNotEmpty) ...[
                    if (hasVkn ||
                        hasTckn ||
                        hasTaxOffice ||
                        hasEmail ||
                        hasPhone)
                      const SizedBox(height: 8),
                    _iconRow(Icons.location_on_outlined, address,
                        multiline: true),
                  ],
                  if (hasNote) ...[
                    const SizedBox(height: 8),
                    Row(
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
                            invoice.note!.trim(),
                            style: theme.textCaption(
                                color: theme.defaultGray500Color),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _labeledRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textMini(color: theme.defaultGray500Color)),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textCaption(color: theme.defaultGray700Color),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _iconRow(IconData icon, String value, {bool multiline = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 14, color: theme.default900Color),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: theme.textCaption(color: theme.defaultGray700Color),
            maxLines: multiline ? 4 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
