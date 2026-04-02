import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:flutter/material.dart';

/// Renk seçici dialog widget'ı.
/// Seçilen renk hex string olarak döner, temizleme durumunda `null` döner.
/// Kullanıcı dialog'u kapatırsa (`pop` ile) sonuç `null` olur.
class ColorPickerDialogWidget extends StatelessWidget {
  final String? currentColor;

  const ColorPickerDialogWidget({
    Key? key, 
    this.currentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;
    final palette = theme.employeeColorPalette;

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  labels.selectColor,
                  style: theme.textLabelBold(color: theme.defaultBlackColor),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: palette.map((color) {
                    final hex = _colorToHex(color);
                    final isSelected = currentColor == hex;
                    return GestureDetector(
                      onTap: () => Navigator.of(context).pop(hex),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? theme.defaultBlackColor
                                : Colors.transparent,
                            width: isSelected ? 3 : 0,
                          ),
                        ),
                        child: isSelected
                            ? Icon(Icons.check,
                                color: theme.defaultWhiteColor, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                if (currentColor != null && currentColor!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(''),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.panelDangerColor,
                        foregroundColor: theme.defaultWhiteColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        labels.removeColor,
                        style: theme.textBody(color: theme.defaultWhiteColor),
                      ),
                    ),
                  ),
                ],
              ],
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
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}
