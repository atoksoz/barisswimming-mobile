import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/shared-preferences/mobile_app_settings_utils.dart';
import 'mobile_app_settings.dart';

import 'dart:io';

class MobileAppSettingsCubit extends Cubit<MobileAppSettings?> {
  MobileAppSettingsCubit() : super(null);

  Map<String, String> _cachedVersions = {}; // Platform-based cached versions

  Future<MobileAppSettings?> loadFromCache() async {
    final cached = await loadMobileAppSettingsFromSharedPref();
    if (cached != null) {
      // Cache platform-based versions
      _cachedVersions = Map<String, String>.from(cached.mobileAppVersions);
      emit(cached);
    }
    return cached;
  }

  Future<bool> updateSettingsIfChanged(MobileAppSettings settings) async {
    final currentPlatform = _getCurrentPlatform();
    final previousVersion = _cachedVersions[currentPlatform];
    final newVersion = settings.mobileAppVersions[currentPlatform] ?? '';

    _cachedVersions = Map<String, String>.from(settings.mobileAppVersions);

    // Önce disk; böylece paralelde çalışan loadFromCache eski prefs okuyup cubit’i ezemez.
    await saveMobileAppSettingsToSharedPref(settings);
    emit(settings);
    
    // Check if version changed for current platform
    return previousVersion != null &&
        previousVersion.isNotEmpty &&
        previousVersion != newVersion;
  }

  Future<void> clearSettings() async {
    _cachedVersions = {};
    emit(null);
    await clearMobileAppSettingsFromSharedPref();
  }

  String? getCachedVersion([String? platform]) {
    final targetPlatform = platform ?? _getCurrentPlatform();
    return _cachedVersions[targetPlatform] ?? state?.mobileAppVersions[targetPlatform];
  }

  // Backward compatibility
  String? get cachedVersion => getCachedVersion();

  String _getCurrentPlatform() {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    // Try to detect HarmonyOS - this might need adjustment based on actual HarmonyOS detection
    return 'harmonyos';
  }
}

