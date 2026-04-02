import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../config/themes/bloc_theme.dart';

Future<void> showNoInternetDialog(BuildContext context) async {
  final String svgPath = BlocTheme.theme.noInternetConnectionSvgPath;

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
              width: 196,
              height: 175,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text(
              AppLabels.current.checkInternetConnection,
              textAlign: TextAlign.center,
              style: BlocTheme.theme.textBody(
                  color: BlocTheme.theme.defaultBlackColor),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: BlocTheme.theme.default500Color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                AppLabels.current.close,
                style: BlocTheme.theme.textBody(
                    color: BlocTheme.theme.defaultBlackColor),
              ),
            ),
          ],
        ),
      );
    },
  );
}
