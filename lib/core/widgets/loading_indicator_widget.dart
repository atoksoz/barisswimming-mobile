import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:flutter/material.dart';

class LoadingIndicatorWidget extends StatelessWidget {
  final double topPadding;
  final double bottomPadding;
  final double size;
  final Color? color;

  const LoadingIndicatorWidget({
    super.key,
    this.topPadding = 0,
    this.bottomPadding = 0,
    this.size = 48,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            EdgeInsetsDirectional.fromSTEB(0, topPadding, 0, bottomPadding),
        child: SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 5,
            color: color ?? BlocTheme.theme.default500Color,
          ),
        ),
      ),
    );
  }
}
