import 'package:e_sport_life/config/app-content/app_content_cubit.dart';
import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/mobile-app-settings/mobile_app_settings_cubit.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/services/mobile_app_settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Müzik okulu / yüzme kursu üye ve eğitmen ana sayfalarında ortak:
/// API `mobile-application/settings` → içerik + [MobileAppSettingsCubit] (tema dahil).
Future<void> loadMobilePanelAppSettings(BuildContext context) async {
  try {
    final externalConfig =
        context.read<ExternalApplicationsConfigCubit>().state;
    if (externalConfig == null) return;
    final apiUrl = externalConfig.apiHamamspaUrl;
    if (apiUrl.isEmpty) return;
    final token = await JwtStorageService.getToken();
    if (token == null || token.isEmpty) return;

    final result = await MobileAppSettingsService.fetchSettings(
      apiHamamSpaUrl: apiUrl,
      token: token,
    );
    if (result == null || !context.mounted) return;

    if (result.content.hasAnyContent) {
      context.read<AppContentCubit>().updateContent(result.content);
    }
    await context
        .read<MobileAppSettingsCubit>()
        .updateSettingsIfChanged(result.settings);
  } catch (_) {}
}
