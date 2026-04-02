import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:flutter/material.dart';

class ImagePopupWidget extends StatelessWidget {
  final ImageProvider? imageProvider;

  const ImagePopupWidget({Key? key, this.imageProvider}) : super(key: key);

  static Future<void> show(BuildContext context,
      {ImageProvider? imageProvider}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ImagePopupWidget(imageProvider: imageProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              color: theme.defaultBlackColor.withOpacity(0.85),
              child: Center(
                child: InteractiveViewer(
                  child: Image(
                    image: imageProvider ??
                        const AssetImage(
                            'assets/images/application_images/profile.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 12,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.defaultWhiteColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: theme.defaultWhiteColor,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
