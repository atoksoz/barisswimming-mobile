import 'package:e_sport_life/config/themes/blue_theme.dart';
import 'package:e_sport_life/config/themes/green_theme.dart';
import 'package:e_sport_life/config/themes/orange_theme.dart';
import 'package:e_sport_life/config/themes/supported_theme.dart';
import 'package:e_sport_life/core/utils/mobile_ui_accent_theme_util.dart';

import '../../config/themes/base_theme.dart';

/// Uygulama açılışındaki varsayılan accent paleti ve tema fabrikası.
///
/// UI kodunda renk/SVG için doğrudan burayı kullanmayın; [BlocTheme.theme] veya
/// `Theme.of(context)` kullanın (bkz. `.cursor/rules/application-theme-convention.mdc`).
///
/// Canlı renk: giriş sonrası `v1/mobile-application/settings` içindeki
/// `mobile_ui_accent` (cache’lenir) ile [BlocTheme] güncellenir.
class ApplicationTheme {
  /// Soğuk başlangıç / çıkış sonrası: yeşil. API `mobile_ui_accent` ile ezilir.
  static const SupportedTheme defaultSupportedTheme = SupportedTheme.GREEN;

  /// API/cache metni → tema. Uygulama: [MobileUiAccentThemeUtil].
  static SupportedTheme supportedThemeFromMobileAccent(String? raw) =>
      MobileUiAccentThemeUtil.toSupportedTheme(
        raw,
        fallback: defaultSupportedTheme,
      );

  static BaseTheme themeFor(SupportedTheme supported) {
    switch (supported) {
      case SupportedTheme.GREEN:
        return GreenTheme();
      case SupportedTheme.ORANGE:
        return OrangeTheme();
      case SupportedTheme.BLUE:
        return BlueTheme();
    }
  }

  /// Soğuk başlangıç ve `main` içi statik erişim için ilk [BaseTheme].
  static BaseTheme get initialBaseTheme => themeFor(defaultSupportedTheme);
}
