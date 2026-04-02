import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../config/themes/bloc_theme.dart';

Future<bool?> confirmDialog(
  BuildContext context, {
  required String message,
  String? path,
  String? confirmButtonText,
  String? cancelButtonText,
  Color? confirmButtonColor,
  Color? confirmButtonTextColor,
  Color? cancelButtonColor,
  Color? cancelButtonTextColor,
}) async {
  final theme = BlocTheme.theme;
  final labels = AppLabels.current;

  return showDialog<bool>(
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
                onTap: () => Navigator.of(context).pop(false),
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
            SvgPicture.asset(
              path ?? theme.attentionSvgPath,
              width: 64,
              height: 65,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textBody(color: theme.defaultBlackColor),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          cancelButtonColor ?? theme.defaultRed700Color,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(theme.panelButtonRadius),
                      ),
                    ),
                    child: Text(
                      cancelButtonText ?? labels.cancel,
                      style: theme.textBody(
                        color:
                            cancelButtonTextColor ?? theme.defaultWhiteColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          confirmButtonColor ?? theme.default500Color,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(theme.panelButtonRadius),
                      ),
                    ),
                    child: Text(
                      confirmButtonText ?? labels.save,
                      style: theme.textBody(
                        color:
                            confirmButtonTextColor ?? theme.defaultBlackColor,
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
