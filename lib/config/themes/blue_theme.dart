import 'package:e_sport_life/core/extensions/hex_color_extension.dart';
import 'package:flutter/material.dart';

import 'base_theme.dart';

/// Mavi tema — **Sky** tonları (klasik Tailwind Blue yerine biraz daha cyan / ferah).
///
/// Özel mavi SVG asset seti yoksa şimdilik [GreenTheme] ile aynı dosya yolları
/// kullanılır; renkler tamamen bu temanın tonlarından gelir.
class BlueTheme extends BaseTheme {
  static final BlueTheme _instance = BlueTheme._();

  BlueTheme._();

  factory BlueTheme() => _instance;

  @override
  Color get primaryColor => HexColor.fromHex('#0EA5E9');

  @override
  Color get accentColor => HexColor.fromHex('#0284C7');

  @override
  ThemeData get data => ThemeData(
        brightness: Brightness.light,
        primaryColor: primaryColor,
        hintColor: accentColor,
        canvasColor: const Color(0xFFEEEEEE),
        scaffoldBackgroundColor: HexColor.fromHex('#FFFFFF'),
        datePickerTheme: DatePickerThemeData(
          headerBackgroundColor: default600Color,
          headerForegroundColor: Colors.white,
          todayForegroundColor: MaterialStateProperty.all(default600Color),
          dayForegroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.white;
            }
            return defaultBlackColor;
          }),
          dayBackgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return default600Color;
            }
            return Colors.transparent;
          }),
          dayStyle: TextStyle(color: defaultBlackColor),
          yearStyle: TextStyle(color: defaultBlackColor),
          weekdayStyle: TextStyle(color: defaultBlackColor),
        ),
        colorScheme: ColorScheme.light(
          primary: default600Color,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: defaultBlackColor,
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 18,
            color: primaryColor,
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            color: primaryColor,
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
          ),
        ),
      );

  @override
  TextStyle get tsHistory => TextStyle(
        fontSize: 120,
        color: const Color(0xFFBDBDBD).withOpacity(0.3),
        fontWeight: FontWeight.w700,
      );

  @override
  TextStyle get text4Xl => TextStyle(
        fontSize: 36,
        color: default800Color,
        fontWeight: FontWeight.w700,
      );

  @override
  Color get colorScoreText => HexColor.fromHex('#0C4A6E');

  @override
  Color get defaultSubColor => HexColor.fromHex('#909090');

  @override
  Color get default50Color => HexColor.fromHex('#F0F9FF');

  @override
  Color get default100Color => HexColor.fromHex('#E0F2FE');

  @override
  Color get default200Color => HexColor.fromHex('#BAE6FD');

  @override
  Color get default300Color => HexColor.fromHex('#7DD3FC');

  @override
  Color get default400Color => HexColor.fromHex('#38BDF8');

  @override
  Color get default500Color => HexColor.fromHex('#0EA5E9');

  @override
  Color get default600Color => HexColor.fromHex('#0284C7');

  @override
  Color get default700Color => HexColor.fromHex('#0369A1');

  @override
  Color get default800Color => HexColor.fromHex('#075985');

  @override
  Color get default900Color => HexColor.fromHex('#0C4A6E');

  @override
  Color get defaultBlackColor => HexColor.fromHex('#000000');

  @override
  Color get defaultWhiteColor => HexColor.fromHex('#FFFFFF');

  @override
  Color get defaultBlue800Color => HexColor.fromHex('#075985');

  @override
  Color get defaultRed700Color => HexColor.fromHex('#B91C1C');

  @override
  Color get defaultOrange500Color => HexColor.fromHex('#F0611F');

  @override
  Color get defaultPuple50Color => HexColor.fromHex('#F5F3FF');

  @override
  Color get defaultAppBarColor => default500Color;

  // SVG paths — mavi varyantlar eklenene kadar yeşil set ile aynı dosyalar.
  @override
  String get noInternetConnectionSvgPath =>
      'assets/images/svg/no_connection_green.svg';

  @override
  String get attentionSvgPath => 'assets/images/svg/attention_green.svg';

  @override
  String get fitnessProgrameSvgPath =>
      'assets/images/svg/fitness_programe_green.svg';

  @override
  String get measurementSvgPath => 'assets/images/svg/measurement_green.svg';

  @override
  String get personalTrainingSvgPath =>
      'assets/images/svg/personal_training_green.svg';

  @override
  String get userSvgPath => 'assets/images/svg/user_blue.svg';

  @override
  String get dietSvgPath => 'assets/images/svg/diet_green.svg';

  @override
  String get groupLessonSvgPath => 'assets/images/svg/group_lessons_green.svg';

  @override
  String get resarvationNowSvgPath => 'assets/images/svg/calendar_green.svg';

  @override
  String get massageSvgPath => 'assets/images/svg/massage_green.svg';

  @override
  String get arrowRightSvgPath => 'assets/images/svg/arrow_right_green.svg';

  @override
  String get doorSvgPath => 'assets/images/svg/door_green.svg';

  @override
  String get turnstileInSvgPath => 'assets/images/svg/turnstile_in_green.svg';

  @override
  String get turnstileOutSvgPath =>
      'assets/images/svg/turnstile_out_green.svg';

  @override
  String get topBgSvgPath => 'assets/images/svg/top_bg_blue.svg';

  @override
  String get desertSvgPath => 'assets/images/svg/desert_green.svg';

  @override
  String get cafeSvgPath => 'assets/images/svg/cafe_green.svg';

  @override
  String get fruitsSvgPath => 'assets/images/svg/fruits_green.svg';

  @override
  String get coldDrinkSvgPath => 'assets/images/svg/cold_drink_green.svg';

  @override
  String get hotDrinkSvgPath => 'assets/images/svg/hot_drink_green.svg';

  @override
  String get appBarTopSvgPath => 'assets/images/svg/appbar_top_blue.svg';

  @override
  String get paymentHistoryBagSvgPath =>
      'assets/images/svg/payment_history_bag_green.svg';

  @override
  String get paymentHistoryMassageSvgPath =>
      'assets/images/svg/payment_history_massage_green.svg';

  @override
  String get paymentHistoryGymSvgPath =>
      'assets/images/svg/payment_history_gym_green.svg';

  @override
  String get bodySvgPath => 'assets/images/svg/body_green.svg';

  @override
  String get subtractSvgPath => 'assets/images/svg/subtract_red.svg';

  @override
  String get suggestionSvgPath => 'assets/images/svg/suggestion_green.svg';

  @override
  String get annoucementSvgPath => 'assets/images/svg/annoucement_blue.svg';

  @override
  String get inviteFriendSvgPath =>
      'assets/images/svg/invite_friend_green.svg';

  @override
  String get walletSvgPath => 'assets/images/svg/wallet_green.svg';

  @override
  String get earnAsYouSpendSvgPath =>
      'assets/images/svg/earn_as_you_spend_green.svg';
}
