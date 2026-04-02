import 'dart:async';

import 'package:e_sport_life/config/ability/mobile_ability_cubit.dart';
import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/mobile-app-settings/mobile_app_settings_cubit.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/config/user-config/user_config_cubit.dart';
import 'package:e_sport_life/core/constants/url/api_hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/constants/url/iam_url_constants.dart';
import 'package:e_sport_life/core/enums/mobile_user_type.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/utils/shared-preferences/locale_cache_utils.dart';
import 'package:e_sport_life/core/services/device_uuid_storage_service.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/utils/shared-preferences/external_applications_config_utils.dart';
import 'package:e_sport_life/core/utils/shared-preferences/user_config_utils.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/core/widgets/warning_dialog_widget.dart';
import 'package:e_sport_life/screen/panel/common/security-code/security_code_screen.dart';
import 'package:e_sport_life/screen/panel/common/tabs/tabs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SliderScreen extends StatefulWidget {
  const SliderScreen({Key? key}) : super(key: key);

  @override
  State<SliderScreen> createState() => _SliderScreenState();
}

class _SliderScreenState extends State<SliderScreen> {
  static const _requestTimeout = Duration(seconds: 3);
  static const _httpUnauthorized = 401;

  @override
  void initState() {
    super.initState();
    _validateTokenAndRedirect();
  }

  Future<void> _validateTokenAndRedirect() async {
    try {
      final token = await JwtStorageService.getToken();
      if (token == null || token.isEmpty) {
        _navigateToSecurityCode();
        return;
      }

      final url = IamUrlConstants.getCheckTokenIsValidUrl();
      final response = await RequestUtil.get(
        url,
        token: token,
        timeout: _requestTimeout,
      );

      if (response != null && response.statusCode == _httpUnauthorized) {
        await JwtStorageService.deleteToken();
        if (!mounted) return;
        await warningDialog(
          context,
          message: AppLabels.current.sessionExpiredReGetCode,
        );
        _navigateToSecurityCode();
        return;
      }

      final settingsCubit = context.read<MobileAppSettingsCubit>();
      if (settingsCubit.state == null) {
        await settingsCubit.loadFromCache();
      }
      final shouldVerifyDevice =
          settingsCubit.state?.allowSingleDeviceOnly ?? false;

      await _initLabelsAndAbilities();

      if (shouldVerifyDevice && response != null) {
        final deviceVerified = await _verifyDevice(token);
        if (deviceVerified) {
          _navigateToTabs();
        }
      } else {
        _navigateToTabs();
      }
    } catch (_) {
      _navigateToTabs();
    }
  }

  Future<void> _initLabelsAndAbilities() async {
    try {
      var userConfig = context.read<UserConfigCubit>().state;
      if (userConfig == null) {
        final storedUser = await loadUserConfigFromSharedPref();
        if (storedUser != null) {
          context.read<UserConfigCubit>().updateUserConfig(storedUser);
          userConfig = storedUser;
        }
      }

      if (userConfig != null) {
        final savedLocale = await LocaleCacheUtils.load();
        AppLabels.init(userConfig.applicationType, locale: savedLocale);

        if (userConfig.userType != MobileUserType.member) {
          await context.read<MobileAbilityCubit>().loadFromCache();
        }
      }
    } catch (_) {
      // Non-blocking: label/ability init failure shouldn't prevent navigation
    }
  }

  Future<bool> _verifyDevice(String token) async {
    final deviceUuid = await DeviceUuidStorageService.getDeviceUuid();

    var userConfig = context.read<UserConfigCubit>().state;
    var externalConfig =
        context.read<ExternalApplicationsConfigCubit>().state;

    if (userConfig == null) {
      final storedUser = await loadUserConfigFromSharedPref();
      if (storedUser != null) {
        context.read<UserConfigCubit>().updateUserConfig(storedUser);
        userConfig = storedUser;
      }
    }

    if (externalConfig == null) {
      final storedExternal =
          await loadExternalApplicationsConfigFromSharedPref();
      if (storedExternal != null) {
        context
            .read<ExternalApplicationsConfigCubit>()
            .updateExternalApplicationsConfig(storedExternal);
        externalConfig = storedExternal;
      }
    }

    if (userConfig == null || externalConfig == null) {
      return true;
    }

    final memberId = userConfig.memberId;
    final apiUrl = externalConfig.apiHamamspaUrl;
    if (memberId.isEmpty || apiUrl.isEmpty) {
      return true;
    }

    final verifyUrl = ApiHamamSpaUrlConstants.getDeviceVerifyUrl(
      apiUrl,
      memberId: memberId,
      deviceUuid: deviceUuid!,
    );

    try {
      final response = await RequestUtil.get(
        verifyUrl,
        token: token,
        timeout: _requestTimeout,
      );
      if (response == null || response.statusCode != 200) {
        if (!mounted) return false;
        await warningDialog(
          context,
          message: AppLabels.current.sessionOpenedOnAnotherDeviceReLogin,
          buttonColor: BlocTheme.theme.defaultRed700Color,
          buttonTextColor: BlocTheme.theme.defaultWhiteColor,
        );
        if (!mounted) return false;
        await DeviceUuidStorageService.deleteDeviceUuid();
        await JwtStorageService.deleteToken();
        if (!mounted) return false;
        _navigateToSecurityCode();
        return false;
      }
    } catch (_) {
      // Non-blocking: verification network error shouldn't block entry
    }

    return true;
  }

  void _navigateToSecurityCode() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SecurityCodeScreen()),
    );
  }

  void _navigateToTabs() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Tabs(index: 0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlocTheme.theme.primaryColor,
      body: const Center(child: LoadingIndicatorWidget()),
    );
  }
}
