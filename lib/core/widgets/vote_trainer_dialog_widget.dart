import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../config/themes/bloc_theme.dart';

Future<int?> voteTrainerDialog(
  BuildContext context, {
  required String message,
  int? initialStar,
  String? path,
}) async {
  final theme = BlocTheme.theme;
  final labels = AppLabels.current;
  final String svgPath = path ?? theme.attentionSvgPath;
  int selectedStar = initialStar ?? 0;

  return showDialog<int>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                svgPath,
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
              Text(
                labels.selectStarRating,
                style: theme.textSmall(color: theme.defaultBlackColor),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedStar
                          ? Icons.star
                          : Icons.star_border_outlined,
                      color: theme.default500Color,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedStar = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.defaultRed700Color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        labels.cancel,
                        style: theme.textBody(
                            color: theme.defaultWhiteColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(selectedStar),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.default500Color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        labels.confirm,
                        style: theme.textBody(
                            color: theme.defaultBlackColor),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      });
    },
  );
}
