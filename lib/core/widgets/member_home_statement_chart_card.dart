import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/constants/url/api_hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/utils/member_statement_chart_buckets_util.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Müzik okulu anasayfa — cari özet + pie grafik.
///
/// Sol: [MemberActivePackageRightsDonutCard] ile aynı kabuk ve kareli satırlar.
/// Sağ: Explore **Tesis Doluluk Oranı** tarzı pie (96×96, `centerSpaceRadius: 32`,
/// dilim `radius: 15`, `startDegreeOffset: -270`).
///
/// Pie: yalnızca toplam satış ([default900Color]) ve toplam tahsilat ([panelWarningColor]);
/// bakiye tutarı metinde gösterilir, grafik diliminde yok.
///
/// Veri: `GET v2/me/statements` — API tüm ekstre satırlarını döner; toplamlar istemcide
/// (`MemberStatementChartBucketsUtil`) hesaplanır (api-system `MemberStatementV2Controller`).
class MemberHomeStatementChartCard extends StatefulWidget {
  const MemberHomeStatementChartCard({
    super.key,
    required this.onTapOpenStatement,
    this.externalTotalDebit,
    this.externalTotalCredit,
    this.externalBalance,
    this.externalItems,
  });

  final VoidCallback onTapOpenStatement;

  /// Dashboard'dan gelen toplam satış/tahsilat/bakiye değerleri.
  /// Sağlanırsa widget kendi API çağrısını yapmaz.
  final double? externalTotalDebit;
  final double? externalTotalCredit;
  final double? externalBalance;
  final List<Map<String, dynamic>>? externalItems;

  @override
  State<MemberHomeStatementChartCard> createState() =>
      _MemberHomeStatementChartCardState();
}

class _MemberHomeStatementChartCardState
    extends State<MemberHomeStatementChartCard> {
  /// Ekran kenarından kart kenarına (her iki yanda); kartı tam genişlikten daraltır.
  static const double _cardHorizontalInset = 28;

  static const double _cardVerticalPadding = 6;
  static const double _rowMinHeight = 118;

  static const double _pieSize = 96;
  static const double _pieCenterSpaceRadius = 32;
  static const double _pieSectionRadius = 15;

  static const double _pieValueEps = 0.005;

  bool _loading = true;
  List<Map<String, dynamic>> _items = const [];

  bool _selfLoadStarted = false;

  @override
  void initState() {
    super.initState();
    if (widget.externalItems != null) {
      _items = widget.externalItems!;
      _loading = false;
    } else {
      _selfLoadStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
  }

  @override
  void didUpdateWidget(covariant MemberHomeStatementChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.externalItems != null && oldWidget.externalItems == null) {
      setState(() {
        _items = widget.externalItems!;
        _loading = false;
      });
    }
  }

  Future<void> _load() async {
    if (!mounted) return;
    if (widget.externalItems != null) {
      setState(() {
        _items = widget.externalItems!;
        _loading = false;
      });
      return;
    }
    try {
      final config = context.read<ExternalApplicationsConfigCubit>().state;
      final apiUrl = config?.apiHamamspaUrl ?? '';
      if (apiUrl.isEmpty) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final url = ApiHamamSpaUrlConstants.getMyStatementsUrl(apiUrl);
      final result = await RequestUtil.getJson(url);
      List<Map<String, dynamic>> list = const [];
      if (result.isSuccess && result.output is List) {
        list = List<Map<String, dynamic>>.from(
          (result.output as List).map((e) => Map<String, dynamic>.from(e)),
        );
      }
      if (mounted) {
        setState(() {
          _items = list;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _items = const [];
          _loading = false;
        });
      }
    }
  }

  String _formatMoney(double v) => '${v.toStringAsFixed(2)} ₺';

  /// Pie merkezi: kuruş ve ₺ yok (tam sayı).
  String _formatBalancePieCenter(double balanceAbs) =>
      balanceAbs.round().toString();

  Widget _exploreStyleMetricRow({
    required BaseTheme theme,
    required bool showSquare,
    required Color squareColor,
    required String text,
    bool emphasizeEmpty = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showSquare)
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsetsDirectional.only(end: 10),
            decoration: BoxDecoration(
              color: squareColor,
              borderRadius: const BorderRadius.all(Radius.circular(3)),
            ),
          ),
        Expanded(
          child: Text(
            text,
            softWrap: false,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: emphasizeEmpty
                ? theme.textCaption(color: theme.default900Color)
                : theme.textBody(color: theme.default900Color),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections({
    required BaseTheme theme,
    required double sale,
    required double collection,
  }) {
    final out = <PieChartSectionData>[];
    if (sale > _pieValueEps) {
      out.add(
        PieChartSectionData(
          value: sale,
          color: theme.default900Color,
          showTitle: false,
          radius: _pieSectionRadius,
        ),
      );
    }
    if (collection > _pieValueEps) {
      out.add(
        PieChartSectionData(
          value: collection,
          color: theme.panelWarningColor,
          showTitle: false,
          radius: _pieSectionRadius,
        ),
      );
    }
    return out;
  }

  Widget _buildExploreStylePieChart({
    required BaseTheme theme,
    required AppLabels labels,
    required List<PieChartSectionData> sections,
    required bool hasPieSlices,
    required double balanceAbs,
    required bool showNoDebtMessageInCenter,
  }) {
    final emptyColor = theme.defaultGray300Color;
    final List<PieChartSectionData> dataSections = sections.isNotEmpty
        ? sections
        : [
            PieChartSectionData(
              value: 1,
              color: emptyColor,
              showTitle: false,
              radius: _pieSectionRadius,
            ),
          ];

    final Widget centerChild = !hasPieSlices
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '—',
                textAlign: TextAlign.center,
                maxLines: 1,
                style: theme.textLabelBold(color: theme.default900Color),
              ),
              if (showNoDebtMessageInCenter) ...[
                const SizedBox(height: 2),
                Text(
                  labels.homeStatementChartNoDebtLine,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textMini(color: theme.defaultGray500Color),
                ),
              ],
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatBalancePieCenter(balanceAbs),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textLabelBold(color: theme.default900Color),
              ),
              if (showNoDebtMessageInCenter) ...[
                const SizedBox(height: 2),
                Text(
                  labels.homeStatementChartNoDebtLine,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textMini(color: theme.defaultGray500Color),
                ),
              ],
            ],
          );

    return SizedBox(
      width: _pieSize,
      height: _pieSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: _pieCenterSpaceRadius,
              startDegreeOffset: -270,
              sections: dataSections,
              pieTouchData: PieTouchData(enabled: false),
            ),
            duration: Duration.zero,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: centerChild,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;
    final outerWidth =
        MediaQuery.sizeOf(context).width - (_cardHorizontalInset * 2);

    return Container(
      margin: EdgeInsetsDirectional.fromSTEB(
        _cardHorizontalInset,
        theme.panelHomeBlockGap,
        _cardHorizontalInset,
        0,
      ),
      width: outerWidth,
      constraints: const BoxConstraints(minHeight: _rowMinHeight),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            spreadRadius: 1,
            color: theme.defaultGray50Color.withValues(alpha: 1 / 255),
          ),
        ],
        color: theme.panelCardBackground,
        border: Border.all(
          color: theme.defaultGray50Color.withValues(alpha: 1 / 255),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: _loading
          ? const SizedBox(
              height: _rowMinHeight,
              child: Center(child: LoadingIndicatorWidget()),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: _cardVerticalPadding),
              child: _buildContentRow(theme, labels),
            ),
    );
  }

  Widget _buildContentRow(BaseTheme theme, AppLabels labels) {
    final balance = widget.externalBalance ??
        MemberStatementChartBucketsUtil.computeListBalance(_items);
    final totalSales = widget.externalTotalDebit ??
        MemberStatementChartBucketsUtil.computeTotalSales(_items);
    final totalCollections = widget.externalTotalCredit ??
        MemberStatementChartBucketsUtil.computeTotalCollections(_items);

    const balanceEps = 0.005;
    final bool hasDebt = balance > balanceEps;
    final bool hasCredit = balance < -balanceEps;

    final balanceAbs = balance.abs();

    final pieSections = _buildPieSections(
      theme: theme,
      sale: totalSales,
      collection: totalCollections,
    );
    final hasPieSlices = pieSections.isNotEmpty;

    final bool showNoDebtInfo = !hasDebt && !hasCredit;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            20,
            0,
            10,
            theme.panelHomeBlockGap,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  labels.homeStatementChartTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textLabelBold(color: theme.default900Color),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatMoney(balanceAbs),
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textLabelBold(
                          color: theme.default900Color,
                        ),
                      ),
                      Text(
                        labels.balance,
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textCaption(
                          color: theme.defaultGray500Color,
                        ),
                      ),
                      if (showNoDebtInfo) ...[
                        const SizedBox(height: 2),
                        Text(
                          labels.homeStatementChartNoDebtLine,
                          textAlign: TextAlign.end,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textCaption(
                            color: theme.defaultGray500Color,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _exploreStyleMetricRow(
                      theme: theme,
                      showSquare: true,
                      squareColor: theme.default900Color,
                      text:
                          '${labels.saleLabel}: ${_formatMoney(totalSales)}',
                    ),
                    SizedBox(height: theme.panelCardSpacing),
                    _exploreStyleMetricRow(
                      theme: theme,
                      showSquare: true,
                      squareColor: theme.panelWarningColor,
                      text:
                          '${labels.collectionLabel}: ${_formatMoney(totalCollections)}',
                    ),
                    if (!hasPieSlices) ...[
                      SizedBox(height: theme.panelHomeBlockGap),
                      Text(
                        labels.homeStatementChartEmpty,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            theme.textCaption(color: theme.defaultGray500Color),
                      ),
                    ],
                    SizedBox(height: theme.panelSectionSpacing),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: InkWell(
                        onTap: widget.onTapOpenStatement,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(6)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 2,
                          ),
                          child: Text(
                            labels.detailedView,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme
                                .textCaptionSemiBold(
                                  color: theme.defaultBlue800Color,
                                )
                                .copyWith(
                                  decoration: TextDecoration.underline,
                                  decorationColor: theme.defaultBlue800Color,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 5,
                  end: 10,
                  top: 0,
                  bottom: 3,
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: _buildExploreStylePieChart(
                    theme: theme,
                    labels: labels,
                    sections: pieSections,
                    hasPieSlices: hasPieSlices,
                    balanceAbs: balanceAbs,
                    showNoDebtMessageInCenter: showNoDebtInfo,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
