import 'dart:ui';

import 'package:e_sport_life/config/themes/bloc_theme.dart';

/// Eski ekranlar için uyumluluk renkleri. Mümkün olduğunda doğrudan [BlocTheme.theme] kullanın.
class ApplicationColor {
  static Color get primary => BlocTheme.theme.default500Color;

  static Color primaryBackground = const Color(0x0fffffff);
  static Color secondaryBackground = const Color(0x0fffffff);

  static Color get secondaryText => BlocTheme.theme.default500Color;

  static Color get primaryText => BlocTheme.theme.defaultGray900Color;

  static Color primaryBlue = const Color(0xff1e40af);
  static Color error = const Color(0xffFF5963);
  static Color primaryHintText = const Color(0xff6B7280);
  static Color info = const Color(0x00ffffff);

  /// Birincil metin / vurgu için koyu ton (temadaki [BaseTheme.default900Color]).
  static Color get fourthText => BlocTheme.theme.default900Color;

  static Color primaryBoldText = const Color.fromARGB(196, 249, 83, 0);
  static Color get primaryBoxBackground => BlocTheme.theme.panelCardBackground;

  static Color get linearStartColor =>
      BlocTheme.theme.default500Color.withAlpha(1);

  static Color mainPageBoxBg = const Color.fromARGB(1, 249, 250, 251);
  static Color defaultYellow = const Color(0xffFBBF24);
  static Color defaultBlue = const Color(0xff60A5FA);
  static Color defaultRed = const Color(0xffDC2626);
}
