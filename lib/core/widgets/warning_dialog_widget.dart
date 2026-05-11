import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../config/themes/bloc_theme.dart';

Future<void> warningDialog(
  BuildContext context, {
  required String message,
  /// Verilirse [path] yerine daire içinde bu ikon gösterilir (ör. başarı: `Icons.check_circle_outline`).
  IconData? leadingIcon,
  Color? leadingIconBackgroundColor,
  Color? leadingIconForegroundColor,
  String? path,
  /// Verilirse [leadingIcon] yokken SVG tek renge boyanır (ör. uyarı görselini nötrleştirmek için).
  Color? leadingSvgColor,
  Color? buttonColor,
  Color? buttonTextColor,
  Color? secondaryButtonColor,
  Color? secondaryButtonTextColor,
  String? primaryButtonText,
  String? secondaryButtonText,
  VoidCallback? onPrimaryPressed,
  VoidCallback? onSecondaryPressed,
}) async {
  final theme = BlocTheme.theme;
  final String resolvedPrimaryButtonText =
      primaryButtonText ?? AppLabels.current.close;
  final String svgPath = path ?? theme.attentionSvgPath;

  Widget leadingGraphic() {
    if (leadingIcon != null) {
      return SizedBox(
        height: 65,
        child: Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: leadingIconBackgroundColor ?? theme.default100Color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              leadingIcon,
              size: 36,
              color: leadingIconForegroundColor ?? theme.default700Color,
            ),
          ),
        ),
      );
    }
    return SvgPicture.asset(
      svgPath,
      width: 64,
      height: 65,
      fit: BoxFit.contain,
      colorFilter: leadingSvgColor != null
          ? ColorFilter.mode(leadingSvgColor!, BlendMode.srcIn)
          : null,
    );
  }
  final Color resolvedButtonColor =
      buttonColor ?? theme.default500Color;
  final Color resolvedButtonTextColor =
      buttonTextColor ?? theme.defaultBlackColor;
  final Color? resolvedSecondaryButtonColor = secondaryButtonColor;
  final Color resolvedSecondaryButtonTextColor =
      secondaryButtonTextColor ?? theme.defaultBlackColor;

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(theme.panelDialogRadius),
        ),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.default500Color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: theme.defaultBlackColor,
                    size: 20,
                  ),
                ),
              ),
            ),
            leadingGraphic(),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textBody(color: theme.defaultBlackColor),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (secondaryButtonText != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onSecondaryPressed?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: resolvedSecondaryButtonColor ??
                            theme.defaultRed700Color,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(theme.panelButtonRadius),
                        ),
                      ),
                      child: Text(
                        secondaryButtonText,
                        style: theme.textBody(
                          color: resolvedSecondaryButtonTextColor,
                        ),
                      ),
                    ),
                  ),
                if (secondaryButtonText != null) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onPrimaryPressed?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: resolvedButtonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(theme.panelButtonRadius),
                      ),
                    ),
                    child: Text(
                      resolvedPrimaryButtonText,
                      style: theme.textBody(
                        color: resolvedButtonTextColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
