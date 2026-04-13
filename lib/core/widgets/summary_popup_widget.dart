import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:flutter/material.dart';

class SummaryPopupWidget extends StatelessWidget {
  final String title;
  /// Boş veya null ise başlık altında gösterilmez.
  final String? subtitle;
  final List<dynamic> items;
  final Widget Function(BaseTheme, Map<String, dynamic>) itemBuilder;
  /// İki ardışık satır için ayırıcı çizgisini gizlemek (ör. cari satış+tahsilat).
  final bool Function(Map<String, dynamic> previous, Map<String, dynamic> next)?
      omitDividerBetween;

  const SummaryPopupWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.items,
    required this.itemBuilder,
    this.omitDividerBetween,
  });

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.65,
        ),
        decoration: BoxDecoration(
          color: theme.defaultWhiteColor,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        title,
                        style:
                            theme.textLabelBold(color: theme.default700Color),
                        textAlign: TextAlign.center,
                      ),
                      if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: theme.textCaption(
                              color: theme.defaultGray500Color),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: theme.default500Color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close,
                          color: theme.defaultBlackColor, size: 20),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  labels.noData,
                  style: theme.textBody(color: theme.defaultGray500Color),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, index) {
                    if (omitDividerBetween != null &&
                        index >= 0 &&
                        index < items.length - 1) {
                      final a = items[index] is Map<String, dynamic>
                          ? items[index] as Map<String, dynamic>
                          : <String, dynamic>{};
                      final b = items[index + 1] is Map<String, dynamic>
                          ? items[index + 1] as Map<String, dynamic>
                          : <String, dynamic>{};
                      if (omitDividerBetween!(a, b)) {
                        return const SizedBox.shrink();
                      }
                    }
                    return Divider(
                      color: theme.default700Color,
                      height: 1,
                    );
                  },
                  itemBuilder: (_, i) {
                    final item = items[i] is Map<String, dynamic>
                        ? items[i] as Map<String, dynamic>
                        : <String, dynamic>{};
                    return itemBuilder(theme, item);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
