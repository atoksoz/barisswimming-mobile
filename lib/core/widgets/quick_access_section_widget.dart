import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:flutter/material.dart';

class QuickAccessSectionWidget extends StatelessWidget {
  final List<Widget> children;

  const QuickAccessSectionWidget({
    Key? key,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.defaultWhiteColor,
        border: Border.all(color: theme.defaultGray300Color, width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            offset: const Offset(1, 2),
            blurRadius: 8,
            color: theme.defaultBlackColor.withOpacity(0.15),
          ),
        ],
      ),
      width: MediaQuery.sizeOf(context).width - 40,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                labels.quickAccess,
                style: theme.textLabelBold(color: theme.default900Color),
              ),
            ),
            ...children,
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
