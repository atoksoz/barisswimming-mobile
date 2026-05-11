import 'dart:convert';

import 'package:e_sport_life/config/app-content/app_content.dart';
import 'package:e_sport_life/config/mobile-app-settings/mobile_app_settings.dart';
import 'package:flutter/foundation.dart';

import '../constants/url/api_hamam_spa_url_constants.dart';
import '../utils/request_util.dart';

class MobileAppSettingsResult {
  final MobileAppSettings settings;
  final AppContent content;

  const MobileAppSettingsResult({
    required this.settings,
    required this.content,
  });
}

class MobileAppSettingsService {
  static Future<MobileAppSettingsResult?> fetchSettings({
    required String apiHamamSpaUrl,
    required String token,
  }) async {
    final url =
        ApiHamamSpaUrlConstants.getMobileApplicationSettingsUrl(apiHamamSpaUrl);
    final response = await RequestUtil.get(url, token: token);
    if (response == null || response.statusCode != 200) {
      return null;
    }

    try {
      final jsonMap = json.decode(response.body);
      final output = jsonMap['output'];
      if (kDebugMode) {
        debugPrint(
          '[MobileAppSettings] GET ${ApiHamamSpaUrlConstants.mobileApplicationSettingsUri} '
          'HTTP ${response.statusCode}',
        );
        if (output is List) {
          Map<String, dynamic>? accentRow;
          for (final e in output) {
            if (e is Map && e['key'] == 'mobile_ui_accent') {
              accentRow = Map<String, dynamic>.from(
                e.map((k, v) => MapEntry(k.toString(), v)),
              );
              break;
            }
          }
          debugPrint(
            '[MobileAppSettings] output list length=${output.length} '
            'mobile_ui_accent row=$accentRow',
          );
        } else {
          debugPrint(
            '[MobileAppSettings] output is not List: ${output.runtimeType}',
          );
        }
      }
      if (output is List) {
        final settings = MobileAppSettings.fromOutput(output);
        if (kDebugMode) {
          debugPrint(
            '[MobileAppSettings] parsed mobileUiAccent="${settings.mobileUiAccent}"',
          );
        }
        return MobileAppSettingsResult(
          settings: settings,
          content: AppContent.fromSettingsOutput(output),
        );
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[MobileAppSettings] parse error: $e\n$st');
      }
    }
    return null;
  }
}


