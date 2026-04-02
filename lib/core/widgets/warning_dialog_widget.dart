import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../config/themes/bloc_theme.dart';

Future<void> warningDialog(
  BuildContext context, {
  required String message,
  String? path,
  Color? buttonColor,
  Color? buttonTextColor,
  Color? secondaryButtonColor,
  Color? secondaryButtonTextColor,
  String? primaryButtonText,
  String? secondaryButtonText,
  VoidCallback? onPrimaryPressed,
  VoidCallback? onSecondaryPressed,
}) async {
  final String resolvedPrimaryButtonText = primaryButtonText ?? AppLabels.current.close;
  final String svgPath = path ?? BlocTheme.theme.attentionSvgPath;
  final Color resolvedButtonColor =
      buttonColor ?? BlocTheme.theme.default500Color;
  final Color resolvedButtonTextColor =
      buttonTextColor ?? BlocTheme.theme.defaultBlackColor;
  final Color? resolvedSecondaryButtonColor = secondaryButtonColor;
  final Color resolvedSecondaryButtonTextColor =
      secondaryButtonTextColor ?? BlocTheme.theme.defaultBlackColor;

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              svgPath,
              width: 64,
              height: 65,
              fit: BoxFit.contain,
              // colorFilter: ColorFilter.mode(
              //   resolvedButtonColor,
              //   BlendMode.srcIn,
              // ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: BlocTheme.theme.textBody(
                  color: BlocTheme.theme.defaultBlackColor),
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
                        backgroundColor: resolvedSecondaryButtonColor ??
                            BlocTheme.theme.defaultRed700Color,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        secondaryButtonText,
                        style: BlocTheme.theme.textBody(
                            color: resolvedSecondaryButtonTextColor),
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
                      backgroundColor: resolvedButtonColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      resolvedPrimaryButtonText,
                      style: BlocTheme.theme.textBody(
                          color: resolvedButtonTextColor),
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
