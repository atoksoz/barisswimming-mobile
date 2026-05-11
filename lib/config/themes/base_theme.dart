import 'package:flutter/material.dart';

import '../../core/extensions/hex_color_extension.dart';

abstract class BaseTheme {
  Color get primaryColor;

  Color get accentColor;

  ThemeData get data;

  TextStyle get tsHistory;

  //todo kullanılmıyor, daha sonra sil
  TextStyle get tsLoserScore => TextStyle(
        color: colorScoreText,
        fontSize: 26,
        fontWeight: FontWeight.w900,
      );

  //todo kullanılmıyor, daha sonra sil
  TextStyle get tsWinnerScore => TextStyle(
        color: colorScoreText,
        fontSize: 36,
        fontWeight: FontWeight.w900,
      );

  TextStyle get text4Xl;

  Color get colorScoreText;

  Color get default50Color;
  Color get default100Color;
  Color get default200Color;
  Color get default300Color;
  Color get default400Color;
  Color get default500Color;
  Color get default600Color;
  Color get default700Color;
  Color get default800Color;
  Color get default900Color;

  Color get defaultBlue800Color;
  Color get defaultWhiteColor;
  Color get defaultAppBarColor;
  Color get defaultRed700Color;
  Color get defaultOrange500Color;
  Color get defaultSubColor;
  Color get defaultPuple50Color;

  double get defaultCircularStrokeWidth => 4;

  Color get defaultBackgroundColor => HexColor.fromHex("#FFFFFF");
  Color get defaultGrayColor => HexColor.fromHex("#111827");

  Color get defaultBlackColor;

  //SVG paths
  String get noInternetConnectionSvgPath;
  String get attentionSvgPath;
  String get fitnessProgrameSvgPath;
  String get measurementSvgPath;
  String get personalTrainingSvgPath;
  String get userSvgPath;
  String get dietSvgPath;
  String get groupLessonSvgPath;
  String get resarvationNowSvgPath;
  String get massageSvgPath;
  String get arrowRightSvgPath;
  String get doorSvgPath;
  String get turnstileInSvgPath;
  String get turnstileOutSvgPath;
  String get topBgSvgPath;
  String get desertSvgPath;
  String get cafeSvgPath;
  String get fruitsSvgPath;
  String get coldDrinkSvgPath;
  String get hotDrinkSvgPath;
  String get appBarTopSvgPath;
  String get paymentHistoryBagSvgPath;
  String get paymentHistoryMassageSvgPath;
  String get paymentHistoryGymSvgPath;
  String get bodySvgPath;
  String get suggestionSvgPath;
  String get inviteFriendSvgPath;
  String get walletSvgPath;
  String get earnAsYouSpendSvgPath;
  String get facebookSvgPath => "assets/images/svg/facebook.svg";
  String get instagramSvgPath => "assets/images/svg/instagram.svg";
  String get tiktokSvgPath => "assets/images/svg/tiktok.svg";
  String get twitterSvgPath => "assets/images/svg/twitter.svg";
  String get youtubeSvgPath => "assets/images/svg/youtube.svg";
  String get errorSvgPath => "assets/images/svg/error.svg";
  String get gateBlueSvgPath => "assets/images/svg/gate_blue.svg";
  String get gateOrangeSvgPath => "assets/images/svg/gate_orange.svg";
  String get gateGreenSvgPath => "assets/images/svg/gate_green.svg";
  String get groupLessonLocationSvgPath => "assets/images/svg/cycle.svg";
  String get annoucementSvgPath;
  String get applicationLogoPath =>
      "assets/images/application_images/application_logo.png";
  String get subtractSvgPath;

  Color get defaultOrange50Color => HexColor.fromHex("#FEF5EE");
  Color get defaultGreyColor => HexColor.fromHex("#81809E");
  Color get orderSummaryColor => HexColor.fromHex("#253058");
  Color get orderSummaryTextColor => HexColor.fromHex("#7C87AA");

  //todo kullanılmıyor, daha sonra sil
  Color get defaultGray50Color => HexColor.fromHex("#F9FAFB");
  Color get defaultGray100Color => HexColor.fromHex("#F6F3F3");
  Color get defaultGray200Color => HexColor.fromHex("#E5E7EB");
  Color get defaultGray300Color => HexColor.fromHex("#D1D5DB");
  Color get defaultGray400Color => HexColor.fromHex("#9CA3AF");
  Color get defaultGray500Color => HexColor.fromHex("#6B7280");
  Color get defaultGray600Color => HexColor.fromHex("#4B5563");
  Color get defaultGray700Color => HexColor.fromHex("#374151");
  Color get defaultGray800Color => HexColor.fromHex("#1F2937");
  Color get defaultGray900Color => HexColor.fromHex("#111827");
  Color get defaultOrange400Color => HexColor.fromHex("#F48243");

  /// Donut/pie grafiklerinde kalan süre / dolu payı gibi sıcak vurgu (amber #FBBF24).
  Color get chartAmberAccentColor => HexColor.fromHex("#FBBF24");

  Color get defaultBlue500Color => HexColor.fromHex("#3B82F6");
  Color get defaultMainColor => HexColor.fromHex("#242424");
//    Color get defaultGray200Color => const Color(0xFFEEEEEE);
//  Color get defaultGray400Color => const Color(0xFFBDBDBD);

  // ─── Panel Renkleri ───
  Color get panelCardBackground => HexColor.fromHex("#F3F4F6");
  Color get panelCardBorder => defaultGray200Color;
  Color get panelHeaderTextColor => default900Color;
  Color get panelSubTextColor => defaultGray500Color;
  Color get panelNavBarColor => default500Color;
  Color get panelNavBarActiveColor => default900Color;
  Color get panelIconColor => default700Color;
  Color get panelDividerColor => defaultGray200Color;
  Color get panelSuccessColor => default700Color; //HexColor.fromHex("#10B981");
  Color get panelWarningColor => HexColor.fromHex("#F59E0B");
  Color get panelWarningDarkColor => HexColor.fromHex("#D97706");
  Color get panelDangerColor => defaultRed700Color;
  Color get panelPaidColor => default500Color;
  Color get panelDebtColor => defaultRed700Color;
  Color get whatsAppGreenColor => const Color(0xFF25D366);
  Color get panelScaffoldBackgroundColor => const Color.fromARGB(1, 249, 250, 251);

  // ─── Renk Paleti (Çalışan renk seçimi vb.) ───
  List<Color> get employeeColorPalette => const [
    // Kırmızı / Pembe
    Color(0xFFE53935), Color(0xFFFF1744), Color(0xFFC62828),
    Color(0xFFD81B60), Color(0xFFE91E63), Color(0xFFAD1457),
    Color(0xFFFF6B6B), Color(0xFF880E4F),
    // Turuncu / Amber
    Color(0xFFFF5722), Color(0xFFFF6D00), Color(0xFFFF8E53),
    Color(0xFFFF9800), Color(0xFFFFA726), Color(0xFFBF360C),
    Color(0xFFE65100), Color(0xFFFF8F00),
    // Sarı / Altın
    Color(0xFFFFC93C), Color(0xFFFFD54F), Color(0xFFFFAB00),
    Color(0xFFF9A825), Color(0xFFFDD835),
    // Yeşil
    Color(0xFF6BCB77), Color(0xFF8BC34A), Color(0xFF4CAF50),
    Color(0xFF2E7D32), Color(0xFF00C853), Color(0xFF1B5E20),
    // Teal / Cyan
    Color(0xFF009688), Color(0xFF00BCD4), Color(0xFF00838F),
    Color(0xFF26A69A), Color(0xFF00695C),
    // Mavi
    Color(0xFF4D96FF), Color(0xFF1E88E5), Color(0xFF0288D1),
    Color(0xFF3F51B5), Color(0xFF5C6BC0), Color(0xFF1565C0),
    Color(0xFF0D47A1), Color(0xFF42A5F5),
    // Mor / Lila
    Color(0xFF9B59B6), Color(0xFF7B1FA2), Color(0xFFAB47BC),
    Color(0xFFCE93D8), Color(0xFF6A1B9A), Color(0xFF4A148C),
    // Kahverengi / Nötr
    Color(0xFF795548), Color(0xFF8D6E63), Color(0xFF5D4037),
    Color(0xFF607D8B), Color(0xFF455A64), Color(0xFF37474F),
    Color(0xFF212121), Color(0xFF424242),
  ];

  // ─── Panel Kart Stilleri ───
  double get panelCardRadius => 16;
  double get panelCardInnerRadius => 12;
  double get panelButtonRadius => 10;
  double get panelDialogRadius => 16;
  double get panelLargeRadius => 20;

  EdgeInsets get panelPagePadding =>
      const EdgeInsets.symmetric(horizontal: 20);
  EdgeInsets get panelCardPadding => const EdgeInsets.all(16);
  EdgeInsets get panelCardInnerPadding => const EdgeInsets.all(12);
  double get panelCardSpacing => 15;
  double get panelSectionSpacing => 20;

  /// Anasayfa kaydırma alanında üst üçlü / slider / özet / hızlı erişim blokları arası dikey boşluk.
  double get panelHomeBlockGap => 10;

  /// Liste kartlarında kullanılan hafif gölge (paket geçmişi vb.).
  double get panelListCardShadowSpread => 1;
  double get panelListCardShadowBlur => 8;
  double get panelListCardShadowOffsetY => 2;
  double get panelListCardShadowOpacity => 0.06;

  /// Ayırıcı ve ince çerçeve kalınlığı.
  double get panelDividerThickness => 1;

  /// Kart satırı ikonları (dosya türü / indir vb.).
  double get panelRowIconSize => 24;
  double get panelRowIconSizeSmall => 20;

  /// İkon ile metin arası yatay boşluk.
  double get panelInlineLeadingGap => 12;

  /// İki metin satırı arası sıkı dikey boşluk.
  double get panelTightVerticalGap => 2;

  /// Paket listesi üst satırı (ad + tarih) minimum yükseklik.
  double get panelPackageTitleRowMinHeight => 20;

  /// Küçük ek / dosya kutusu dolgu ve kartlar arası dikey ara (8px).
  double get panelCompactInset => 8;

  BoxDecoration get panelCardDecoration => BoxDecoration(
        color: defaultWhiteColor,
        borderRadius: BorderRadius.circular(panelCardRadius),
        boxShadow: [
          BoxShadow(
            color: defaultBlackColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  BoxDecoration get panelSurfaceDecoration => BoxDecoration(
        color: panelCardBackground,
        borderRadius: BorderRadius.circular(panelLargeRadius),
      );

  // ─── Tipografi Temeli ───
  String get fontFamily => 'Inter';

  // Genel text stilleri — renk parametresi ile özelleştirilebilir
  TextStyle textDisplay({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 42,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
        color: color ?? default500Color,
      );

  TextStyle textHeadline({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 30,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: color ?? defaultGray900Color,
      );

  TextStyle textTitle({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: color ?? defaultGray900Color,
      );

  TextStyle textTitleSemiBold({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: color ?? defaultGrayColor,
      );

  TextStyle textSubtitle({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
        color: color ?? default500Color,
      );

  TextStyle textError({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 21,
        fontWeight: FontWeight.w600,
        color: color ?? defaultRed700Color,
      );

  TextStyle textBodyLarge({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
        color: color ?? defaultGray900Color,
      );

  TextStyle textBody({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color ?? defaultGray900Color,
      );

  TextStyle textBodyBold({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color ?? defaultGray900Color,
      );

  TextStyle textSmall({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color ?? defaultGray700Color,
      );

  TextStyle textSmallNormal({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: color ?? defaultGray900Color,
      );

  TextStyle textSmallSemiBold({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color ?? defaultGray900Color,
      );

  TextStyle textCaption({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color ?? defaultGray500Color,
      );

  TextStyle textCaptionSemiBold({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color ?? defaultGray900Color,
      );

  TextStyle textMini({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: color ?? defaultGray500Color,
      );

  TextStyle textCounter({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 36,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: color ?? defaultGray700Color,
      );

  TextStyle textLabel({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: color ?? defaultGray900Color,
      );

  TextStyle textLabelBold({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: color ?? defaultGray900Color,
      );

  // ─── Panel Text Stilleri ───
  TextStyle get panelHeaderStyle => TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: panelHeaderTextColor,
      );

  TextStyle get panelTitleStyle => TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: default900Color,
      );

  TextStyle get panelBodyStyle => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: default900Color,
      );

  TextStyle get panelSubtitleStyle => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: panelSubTextColor,
      );

  TextStyle get panelCaptionStyle => TextStyle(
        fontFamily: fontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: default900Color.withOpacity(0.5),
      );

  TextStyle get panelButtonTextStyle => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: defaultBlackColor,
      );

  // ─── Form Input Stilleri ───
  TextStyle inputTextStyle({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        letterSpacing: 0,
        color: color ?? defaultBlackColor,
      );

  TextStyle inputLabelStyle({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        letterSpacing: 0,
        color: color ?? defaultBlackColor,
      );

  TextStyle inputHintStyle({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        letterSpacing: 2,
        fontWeight: FontWeight.normal,
        color: color ?? defaultGray500Color,
      );

  InputDecoration inputDecoration({
    required String labelText,
    Color? borderColor,
    Color? labelColor,
    Color? hintColor,
    String? hintText,
    String? counterText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool readOnly = false,
  }) {
    final bColor = borderColor ?? (readOnly ? defaultGray400Color : defaultBlackColor);
    return InputDecoration(
      labelText: labelText,
      labelStyle: inputLabelStyle(color: labelColor ?? bColor),
      alignLabelWithHint: true,
      hintText: hintText,
      hintStyle: inputHintStyle(color: hintColor),
      counterText: counterText,
      filled: readOnly,
      fillColor: readOnly ? defaultGray200Color : null,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: bColor, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: bColor, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: defaultRed700Color, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: defaultRed700Color, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }


}
