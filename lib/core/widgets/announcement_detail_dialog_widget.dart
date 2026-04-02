import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/data/model/announcement_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Future<void> showAnnouncementDetailDialog(
  BuildContext context,
  AnnouncementModel announcement,
) async {
  final theme = BlocTheme.theme;

  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.defaultWhiteColor,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    SvgPicture.asset(
                      theme.annoucementSvgPath,
                      width: 64,
                      height: 64,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      announcement.title,
                      textAlign: TextAlign.center,
                      style:
                          theme.textLabelBold(color: theme.defaultBlackColor),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      announcement.description,
                      textAlign: TextAlign.left,
                      style: theme
                          .textBody(color: theme.defaultGray500Color)
                          .copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Container(
                  width: 32,
                  height: 32,
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
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      );
    },
  );
}
