import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:flutter/material.dart';

class StarRatingWidget extends StatelessWidget {
  final int rate;
  final double iconSize;
  final Color? color;

  const StarRatingWidget({
    Key? key,
    required this.rate,
    this.iconSize = 20,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rate ? Icons.star : Icons.star_border,
          color: color ?? BlocTheme.theme.defaultOrange500Color,
          size: iconSize,
        );
      }),
    );
  }
}
