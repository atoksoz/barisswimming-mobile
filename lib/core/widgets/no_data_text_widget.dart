import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:flutter/material.dart';

class NoDataTextWidget extends StatelessWidget {
  final String? text;
  final TextAlign textAlign;
  final Color? color;

  const NoDataTextWidget({
    Key? key,
    this.text,
    this.textAlign = TextAlign.center,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;

    return Center(
      child: Text(
        text ?? AppLabels.current.noData,
        textAlign: textAlign,
        maxLines: 2,
        softWrap: true,
        style: theme.textSubtitle(
          color: color ?? theme.panelSubTextColor,
        ),
      ),
    );
  }
}
