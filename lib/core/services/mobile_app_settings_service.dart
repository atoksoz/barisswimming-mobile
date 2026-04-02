import 'dart:convert';

import 'package:e_sport_life/config/app-content/app_content.dart';
import 'package:e_sport_life/config/mobile-app-settings/mobile_app_settings.dart';

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
      if (output is List) {
        return MobileAppSettingsResult(
          settings: MobileAppSettings.fromOutput(output),
          content: AppContent.fromSettingsOutput(output),
        );
      }
    } catch (_) {}
    return null;
  }
}


