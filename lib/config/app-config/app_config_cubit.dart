import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppConfigState {
  final String appDisplayName;
  final String welcomeMessage;
  final String developer;
  final bool useStaticContent;
  /// Kurum/tesis kuralları (`facility_rules`): yoksa [useStaticContent] ile aynı; set edilirse yalnızca bu içerik için uzaktan/asset ayrımı.
  final bool useStaticFacilityRules;
  /// [useStaticContent] true iken KVKK bu asset dosyasından; false iken önce uzaktan, yoksa buradan.
  final String kvkkContentAsset;
  final String securityCodeHeaderMode;
  final String securityCodeHeaderImage;
  final double securityCodeWaveStartOffsetBottom;
  final double securityCodeWaveControl1OffsetBottom;
  final double securityCodeWaveMidOffsetBottom;
  final double securityCodeWaveControl2OffsetBottom;
  final double securityCodeWaveEndOffsetBottom;

  AppConfigState({
    required this.appDisplayName,
    required this.welcomeMessage,
    required this.developer,
    required this.useStaticContent,
    required this.useStaticFacilityRules,
    required this.kvkkContentAsset,
    required this.securityCodeHeaderMode,
    required this.securityCodeHeaderImage,
    required this.securityCodeWaveStartOffsetBottom,
    required this.securityCodeWaveControl1OffsetBottom,
    required this.securityCodeWaveMidOffsetBottom,
    required this.securityCodeWaveControl2OffsetBottom,
    required this.securityCodeWaveEndOffsetBottom,
  });

  factory AppConfigState.initial() {
    return AppConfigState(
      appDisplayName: '',
      welcomeMessage: '',
      developer: '',
      useStaticContent: true,
      useStaticFacilityRules: true,
      kvkkContentAsset: 'assets/config/kvkk.json',
      securityCodeHeaderMode: 'standard',
      securityCodeHeaderImage:
          'assets/images/application_images/verification_screen_bg.png',
      securityCodeWaveStartOffsetBottom: 8,
      securityCodeWaveControl1OffsetBottom: 45,
      securityCodeWaveMidOffsetBottom: 24,
      securityCodeWaveControl2OffsetBottom: 2,
      securityCodeWaveEndOffsetBottom: 16,
    );
  }
}

class AppConfigCubit extends Cubit<AppConfigState> {
  AppConfigCubit() : super(AppConfigState.initial());

  Future<void> loadConfig() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/config/app_config.json');
      final jsonMap = json.decode(jsonString);

      final appDisplayName = jsonMap['app_display_name'] ?? '';
      final welcomeMessage = jsonMap['welcome_message'] ?? '';
      final developer = jsonMap['developer'] ?? '';
      final useStaticContent = jsonMap['use_static_content'] ?? true;
      final useStaticFacilityRules = jsonMap.containsKey(
              'use_static_facility_rules')
          ? _readBool(jsonMap['use_static_facility_rules'], useStaticContent)
          : useStaticContent;
      final kvkkContentAsset = jsonMap['kvkk_content_asset'] is String &&
              (jsonMap['kvkk_content_asset'] as String).isNotEmpty
          ? jsonMap['kvkk_content_asset'] as String
          : 'assets/config/kvkk.json';
      final securityCodeHeaderMode =
          jsonMap['security_code_header_mode'] ?? 'standard';
      final securityCodeHeaderImage = jsonMap['security_code_header_image'] ??
          'assets/images/application_images/verification_screen_bg.png';
      final securityCodeWaveStartOffsetBottom =
          _readDouble(jsonMap['security_code_wave_start_offset_bottom'], 8);
      final securityCodeWaveControl1OffsetBottom =
          _readDouble(jsonMap['security_code_wave_control1_offset_bottom'], 45);
      final securityCodeWaveMidOffsetBottom =
          _readDouble(jsonMap['security_code_wave_mid_offset_bottom'], 24);
      final securityCodeWaveControl2OffsetBottom =
          _readDouble(jsonMap['security_code_wave_control2_offset_bottom'], 2);
      final securityCodeWaveEndOffsetBottom =
          _readDouble(jsonMap['security_code_wave_end_offset_bottom'], 16);

      emit(AppConfigState(
          appDisplayName: appDisplayName,
          welcomeMessage: welcomeMessage,
          developer: developer,
          useStaticContent: useStaticContent,
          useStaticFacilityRules: useStaticFacilityRules,
          kvkkContentAsset: kvkkContentAsset,
          securityCodeHeaderMode: securityCodeHeaderMode,
          securityCodeHeaderImage: securityCodeHeaderImage,
          securityCodeWaveStartOffsetBottom: securityCodeWaveStartOffsetBottom,
          securityCodeWaveControl1OffsetBottom:
              securityCodeWaveControl1OffsetBottom,
          securityCodeWaveMidOffsetBottom: securityCodeWaveMidOffsetBottom,
          securityCodeWaveControl2OffsetBottom:
              securityCodeWaveControl2OffsetBottom,
          securityCodeWaveEndOffsetBottom: securityCodeWaveEndOffsetBottom));
    } catch (e) {
      print('Config yüklenirken hata oluştu: $e');
      // Hata durumunda varsayılan değerleri tut
      emit(AppConfigState.initial());
    }
  }

  bool _readBool(dynamic value, bool fallback) {
    if (value is bool) return value;
    if (value is String) {
      final s = value.toLowerCase();
      if (s == 'true' || s == '1' || s == 'yes' || s == 'on') return true;
      if (s == 'false' || s == '0' || s == 'no' || s == 'off') return false;
    }
    if (value is num) return value != 0;
    return fallback;
  }

  double _readDouble(dynamic value, double fallback) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? fallback;
    }

    return fallback;
  }
}
