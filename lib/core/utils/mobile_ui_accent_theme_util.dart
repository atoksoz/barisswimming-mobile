import 'package:e_sport_life/config/themes/supported_theme.dart';

/// Panel/API `mobile_ui_accent` metnini [SupportedTheme] değerine çevirir.
///
/// İzin verilen anahtar kelimeler backend ile uyumlu tutulur (`green`, `blue`, …).
final class MobileUiAccentThemeUtil {
  MobileUiAccentThemeUtil._();

  /// [raw] boş veya tanınmıyorsa [fallback] döner (varsayılan [SupportedTheme.GREEN]).
  static SupportedTheme toSupportedTheme(
    String? raw, {
    SupportedTheme fallback = SupportedTheme.GREEN,
  }) {
    final s = raw?.trim().toLowerCase() ?? '';
    if (s.isEmpty) {
      return fallback;
    }
    switch (s) {
      case 'orange':
      case 'turuncu':
        return SupportedTheme.ORANGE;
      case 'blue':
      case 'mavi':
        return SupportedTheme.BLUE;
      case 'green':
      case 'yesil':
      case 'yeşil':
      case 'g':
        return SupportedTheme.GREEN;
      default:
        return fallback;
    }
  }
}
