import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:flutter/material.dart';

/// Verdiğim dersler / yoklama raporu vb. — başlangıç-bitiş tarih alanları.
///
/// Başlangıç: dolgu + çerçeve accent (`default500Color`).
/// Bitiş: çerçeve accent, iç beyaz.
enum TrainerDateFilterFieldVariant {
  startPrimaryFilled,
  endAccentBorderWhiteFill,
}

/// Başlık kutunun içinde üstte [textMini], tarih [textBody].
class TrainerDateFilterField extends StatelessWidget {
  const TrainerDateFilterField({
    super.key,
    required this.theme,
    required this.variant,
    required this.caption,
    required this.controller,
    required this.onTap,
  });

  final BaseTheme theme;
  final TrainerDateFilterFieldVariant variant;
  final String caption;
  final TextEditingController controller;
  final VoidCallback onTap;

  InputDecoration _outlineDecoration({
    required Color borderColor,
    required bool filled,
    Color? fillColor,
  }) {
    return InputDecoration(
      filled: filled,
      fillColor: fillColor,
      isDense: true,
      contentPadding: theme.panelCardInnerPadding,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.defaultRed700Color, width: 1),
        borderRadius: BorderRadius.circular(25),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.defaultRed700Color, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = theme.default500Color;
    final (borderColor, fillColor) = switch (variant) {
      TrainerDateFilterFieldVariant.startPrimaryFilled => (accent, accent),
      TrainerDateFilterFieldVariant.endAccentBorderWhiteFill =>
        (accent, theme.defaultWhiteColor),
    };

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: InputDecorator(
              decoration: _outlineDecoration(
                borderColor: borderColor,
                filled: true,
                fillColor: fillColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    caption,
                    style: theme.textMini(color: theme.defaultBlackColor),
                  ),
                  SizedBox(height: theme.panelTightVerticalGap * 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: theme.defaultBlackColor,
                        size: theme.panelRowIconSizeSmall,
                      ),
                      SizedBox(width: theme.panelCompactInset),
                      Expanded(
                        child: Text(
                          controller.text,
                          style:
                              theme.textBody(color: theme.defaultBlackColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
