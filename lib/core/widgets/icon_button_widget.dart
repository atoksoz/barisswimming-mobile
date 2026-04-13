import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../config/themes/bloc_theme.dart';

Widget iconButtonWidget(
    {required dynamic icon,
    required String text,
    required VoidCallback onTap,
    required EdgeInsetsGeometry margin,
    double? iconWidth,
    double? iconHeight,
    bool? centerText,
    Color? iconColor,
    String? badge,
    TextDecoration? badgeTextDecoration}) {
  final theme = BlocTheme.theme;
  final shouldCenterText = centerText ?? false;
  final w = iconWidth ?? 65;
  final h = iconHeight ?? 50;

  Widget iconWidget;
  if (icon is IconData) {
    iconWidget = Icon(
      icon,
      size: h,
      color: iconColor ?? theme.default900Color,
    );
  } else {
    iconWidget = SvgPicture.asset(
      icon as String,
      width: w,
      height: h,
      fit: BoxFit.contain,
      colorFilter: iconColor != null
          ? ColorFilter.mode(iconColor, BlendMode.srcIn)
          : null,
    );
  }

  return Expanded(
    child: InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.panelCardBackground,
          border: Border.all(
            color: theme.defaultGray50Color,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        margin: margin,
        width: 94,
        height: 102,
        child: Column(
          mainAxisAlignment: shouldCenterText
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  iconWidget,
                  if (badge != null)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.default700Color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badge,
                          style: theme.textMini(color: theme.defaultWhiteColor).copyWith(
                                decoration: badgeTextDecoration,
                                decorationColor: theme.defaultWhiteColor,
                                color: theme.defaultWhiteColor,
                              ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            shouldCenterText
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              text,
                              textAlign: TextAlign.center,
                              softWrap: true,
                              style: theme
                                  .textSmallSemiBold(
                                      color: theme.default900Color)
                                  .copyWith(letterSpacing: 0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: theme
                              .textSmallSemiBold(
                                  color: theme.default900Color)
                              .copyWith(letterSpacing: 0),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    ),
  );
}
