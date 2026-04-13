import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Müzik okulu anasayfa — Explore’daki “Abonelik Bilgileri” kartı düzeninde
/// Σ kalan hak / Σ toplam hak donut’u.
///
/// Tüm kutu tıklanmaz; [onTapDetailedView] yalnızca “Detaylı incele” satırında,
/// [onTapNearExpiry] yalnızca yakında bitecek uyarı satırında.
class MemberActivePackageRightsDonutCard extends StatelessWidget {
  const MemberActivePackageRightsDonutCard({
    super.key,
    required this.theme,
    required this.title,
    required this.remainingLegend,
    required this.usedLegend,
    required this.emptyStateLine,
    required this.detailedViewLabel,
    required this.remaining,
    required this.totalQuantity,
    required this.loading,
    this.showNearExpiryWarning = false,
    this.nearExpiryWarningLabel = '',
    this.onTapNearExpiry,
    this.onTapDetailedView,
  });

  final BaseTheme theme;
  final String title;
  final String remainingLegend;
  final String usedLegend;
  final String emptyStateLine;
  final String detailedViewLabel;
  final int remaining;
  final int totalQuantity;
  final bool loading;
  final bool showNearExpiryWarning;
  final String nearExpiryWarningLabel;
  final VoidCallback? onTapNearExpiry;
  final VoidCallback? onTapDetailedView;

  /// Yükleme göstergesi ve minimum kart yüksekliği (içerik daha uzunsa kart büyür).
  static const double _rowHeight = 115;
  static const double _chartSize = 100;
  static const double _sectionRadius = 15;
  static const double _centerSpace = 34;

  @override
  Widget build(BuildContext context) {
    final outerWidth = MediaQuery.sizeOf(context).width - 40;

    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
      width: outerWidth,
      constraints: const BoxConstraints(minHeight: _rowHeight),
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
      child: loading
          ? const SizedBox(
              height: _rowHeight,
              child: Center(child: LoadingIndicatorWidget()),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textLabelBold(
                                color: theme.default900Color,
                              ),
                            ),
                          ),
                          if (totalQuantity > 0) ...[
                            _exploreStyleMetricRow(
                              showSquare: remaining > 0,
                              squareColor: theme.default900Color,
                              text: '$remainingLegend: $remaining',
                            ),
                            const SizedBox(height: 3),
                            _exploreStyleMetricRow(
                              showSquare: true,
                              squareColor: theme.panelWarningColor,
                              text:
                                  '$usedLegend: ${(totalQuantity - remaining.clamp(0, totalQuantity)).clamp(0, totalQuantity)}',
                            ),
                          ] else
                            _exploreStyleMetricRow(
                              showSquare: false,
                              squareColor: theme.default900Color,
                              text: emptyStateLine,
                              emphasizeEmpty: true,
                            ),
                          if (showNearExpiryWarning &&
                              nearExpiryWarningLabel.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: InkWell(
                                onTap: onTapNearExpiry,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(6),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                    horizontal: 2,
                                  ),
                                  child: Text(
                                    nearExpiryWarningLabel,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme
                                        .textCaptionSemiBold(
                                          color: theme.panelWarningColor,
                                        )
                                        .copyWith(
                                          decoration:
                                              TextDecoration.underline,
                                          decorationColor:
                                              theme.panelWarningColor,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: InkWell(
                              onTap: onTapDetailedView,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(6),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 2,
                                ),
                                child: Text(
                                  detailedViewLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme
                                      .textCaptionSemiBold(
                                        color: theme.defaultBlue800Color,
                                      )
                                      .copyWith(
                                        decoration: TextDecoration.underline,
                                        decorationColor:
                                            theme.defaultBlue800Color,
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
                        top: 5,
                        bottom: 5,
                      ),
                      child: Center(
                        child: _buildChart(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _exploreStyleMetricRow({
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

  Widget _buildChart() {
    final remainColor = theme.default900Color;
    final usedColor = theme.panelWarningColor;
    final emptyColor = theme.defaultGray300Color;

    if (totalQuantity <= 0) {
      return SizedBox(
        width: _chartSize,
        height: _chartSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: _centerSpace,
                startDegreeOffset: -90,
                sections: [
                  PieChartSectionData(
                    value: 1,
                    color: emptyColor,
                    showTitle: false,
                    radius: _sectionRadius,
                  ),
                ],
                pieTouchData: PieTouchData(enabled: false),
              ),
              duration: Duration.zero,
            ),
            Text(
              '—',
              textAlign: TextAlign.center,
              style: theme.textBodyBold(color: theme.default900Color),
            ),
          ],
        ),
      );
    }

    final capRemain = remaining.clamp(0, totalQuantity);
    final used = (totalQuantity - capRemain).clamp(0, totalQuantity);
    final remainD = capRemain.toDouble();
    final usedD = used.toDouble();

    final List<PieChartSectionData> sections;
    if (remainD <= 0 && usedD > 0) {
      sections = [
        PieChartSectionData(
          value: usedD,
          color: usedColor,
          showTitle: false,
          radius: _sectionRadius,
        ),
      ];
    } else if (usedD <= 0 && remainD > 0) {
      sections = [
        PieChartSectionData(
          value: remainD,
          color: remainColor,
          showTitle: false,
          radius: _sectionRadius,
        ),
      ];
    } else {
      sections = [
        PieChartSectionData(
          value: remainD,
          color: remainColor,
          showTitle: false,
          radius: _sectionRadius,
        ),
        PieChartSectionData(
          value: usedD,
          color: usedColor,
          showTitle: false,
          radius: _sectionRadius,
        ),
      ];
    }

    return SizedBox(
      width: _chartSize,
      height: _chartSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: _centerSpace,
              startDegreeOffset: -90,
              sections: sections,
              pieTouchData: PieTouchData(enabled: false),
            ),
            duration: Duration.zero,
          ),
          Text(
            '$remaining',
            textAlign: TextAlign.center,
            style: theme.textBodyBold(color: theme.default900Color),
          ),
        ],
      ),
    );
  }
}
