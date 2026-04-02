import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../config/themes/bloc_theme.dart';

Future<bool> customConfirmationDialog(
  BuildContext context, {
  required String message,
  required String svgPath,
  String? confirmText,
  String? cancelText,
}) async {
  final resolvedConfirmText = confirmText ?? AppLabels.current.confirm;
  final resolvedCancelText = cancelText ?? AppLabels.current.cancel;
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.all(20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  svgPath,
                  width: 64,
                  height: 64,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: BlocTheme.theme.textBody(
                      color: BlocTheme.theme.defaultBlackColor),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BlocTheme.theme.defaultRed700Color,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          resolvedCancelText,
                          style: BlocTheme.theme.textBody(
                              color: BlocTheme.theme.defaultWhiteColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BlocTheme.theme.default500Color,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          resolvedConfirmText,
                          style: BlocTheme.theme.textBody(
                              color: BlocTheme.theme.defaultBlackColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ) ??
      false; // kullanıcı dialogu kapatırsa varsayılan false döner
}
