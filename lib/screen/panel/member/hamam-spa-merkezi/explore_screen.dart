import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_sport_life/config/announcement/announcement_cubit.dart';
import 'package:e_sport_life/config/app-content/app_content_cubit.dart';
import 'package:e_sport_life/config/external-applications-config/external_applications_config.dart';
import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/mobile-app-settings/mobile_app_settings.dart';
import 'package:e_sport_life/config/mobile-app-settings/mobile_app_settings_cubit.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/constants/url/api_hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/constants/url/hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/data/model/category_model.dart';
import 'package:e_sport_life/data/model/open_order_model.dart';
import 'package:e_sport_life/core/widgets/announcement_icon_widget.dart';
import 'package:e_sport_life/core/widgets/quick_access_section_widget.dart';
import 'package:e_sport_life/screen/closet-screen/closet_summary_screen.dart';
import 'package:e_sport_life/screen/diet-screen/diet_screen.dart';
import 'package:e_sport_life/screen/group-lesson-screen/group_lesson_screen.dart';
import 'package:e_sport_life/screen/panel/member/invite-friend/invite_friend_screen.dart';
import 'package:e_sport_life/screen/measurement-screen/measurement_history_screen.dart';
import 'package:e_sport_life/screen/product-screen/products_screen.dart';
import 'package:e_sport_life/screen/panel/member/qr-code/member_closet_qr_screen.dart';
import 'package:e_sport_life/screen/resarvation-now-screen/resarvation_now_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:e_sport_life/config/user-config/user_config.dart';
import 'package:e_sport_life/config/user-config/user_config_cubit.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/mobile_app_settings_service.dart';
import 'package:e_sport_life/core/services/slider_images_service.dart';
import 'package:e_sport_life/core/utils/shared-preferences/external_applications_config_utils.dart';
import 'package:e_sport_life/core/utils/shared-preferences/member_status_utils.dart';
import 'package:e_sport_life/core/utils/shared-preferences/slider_utils.dart';
import 'package:e_sport_life/core/utils/shared-preferences/user_config_utils.dart';
import 'package:e_sport_life/core/widgets/icon_button_widget.dart';
import 'package:e_sport_life/core/widgets/image_popup_widget.dart';
import 'package:e_sport_life/core/widgets/warning_dialog_widget.dart';
import 'package:e_sport_life/data/model/member_detail_response_model.dart';
import 'package:e_sport_life/data/model/member_register_chart_model.dart';
import 'package:e_sport_life/screen/earn-as-you-spend-screen/earn_as_you_spend_screen.dart';
import 'package:e_sport_life/screen/fitness-programe-screen/fitness_programe_screen.dart';
import 'package:e_sport_life/screen/panel/member/hamam-spa-merkezi/gym_history_screen.dart';
import 'package:e_sport_life/screen/package-screen/massage_package_history_screen.dart';
import 'package:e_sport_life/screen/package-screen/pt_package_history_screen.dart';
import 'package:e_sport_life/screen/virtual-wallet-screen/virtual_wallet_screen.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  List<String> sliderImages = [];
  int _sliderWaitTime = 10; // Varsayılan 10 saniye
  static String _name = "";
  ImageProvider? _imageProviderThumb = null;
  ImageProvider? _imageProvider = null;
  MemberDetailResponse? _memberDetailResponse;
  MemberRegisterChartModel? _memberRegisterChartModel;
  OpenOrderModel? _openOrderModel;
  bool _isFetchingMobileSettings = false;

  Future<void> getDashboardData() async {
    try {
      // Cubit oluşturulurken prefs async yükleniyor; initState bazen yüklemeden
      // önce çalışır (özellikle release/cold start). Önce prefs senkron yükle.
      await context
          .read<ExternalApplicationsConfigCubit>()
          .loadExternalApplicationsConfig();

      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;

      if (externalApplicationConfig == null) {
        debugPrint(
          '[HamamExplore][dashboard] ExternalApplicationsConfig yok — '
          'SharedPreferences içinde kayıtlı kurulum/kurumsal yapı bulunamadı.',
        );
        return;
      }

      late final String hamamSpaUrl;
      if (externalApplicationConfig.apiHamamspaUrl.isNotEmpty) {
        hamamSpaUrl = ApiHamamSpaUrlConstants
            .getHamamSpaMerkeziMemberExploreDashboardUrl(
                externalApplicationConfig.apiHamamspaUrl);
      } else {
        final baseHamam = externalApplicationConfig.hamamspaApiUrl;
        if (baseHamam.isEmpty) {
          if (kDebugMode) {
            debugPrint(
              '[HamamExplore][dashboard] api_host ve hamamspaApiUrl boş — '
              'dashboard isteği atılamadı.',
            );
          }
          return;
        }
        hamamSpaUrl =
            HamamSpaUrlConstants.getMemberDashboardDataUrl(baseHamam);
      }
      if (kDebugMode) {
        debugPrint('[HamamExplore][dashboard] GET $hamamSpaUrl');
      }

      final String token = await JwtStorageService.getToken() as String;
      var response = await RequestUtil.get(hamamSpaUrl, token: token);

      if (response == null || response.statusCode != 200) {
        if (kDebugMode) {
          debugPrint(
            '[HamamExplore][dashboard] İstek başarısız '
            'status=${response?.statusCode} body=${response?.body}',
          );
        }
        return;
      }

      final String rawBody = response.body;
      if (kDebugMode) {
        debugPrint(
          '[HamamExplore][dashboard] Yanıt (${rawBody.length} karakter):\n'
          '$rawBody',
        );
      }

      final Map<String, dynamic> json = jsonDecode(rawBody);

      if (kDebugMode) {
        debugPrint(
          '[HamamExplore][dashboard] Üst seviye anahtarlar: ${json.keys.toList()}',
        );
        final out = json['output'];
        debugPrint(
          '[HamamExplore][dashboard] json["output"] runtimeType=${out.runtimeType}',
        );
        if (out is Map<String, dynamic>) {
          debugPrint(
            '[HamamExplore][dashboard] output içi anahtarlar: '
            '${out.keys.toList()}',
          );
          final regs = out['member_registers'];
          debugPrint(
            '[HamamExplore][dashboard] member_registers tipi=${regs.runtimeType} '
            'uzunluk=${regs is List ? regs.length : "n/a"}',
          );
        }
      }

      final memberDetail = MemberDetailResponse.fromJson(json);

      if (kDebugMode) {
        debugPrint(
          '[HamamExplore][dashboard] Parse OK — memberRegisters='
          '${memberDetail.memberRegisters.length} '
          'member.id=${memberDetail.member.id}',
        );
      }

      setState(() {
        _memberDetailResponse = memberDetail;
        _memberRegisterChartModel = MemberRegisterChartModel.fromRegisterList(
          memberDetail.memberRegisters,
        );
      });

      await saveGymFrozenStatusToCache(
          _memberRegisterChartModel?.isGymFrozen ?? false);

      await context.read<UserConfigCubit>().loadUserConfig();

      final userConfig = context.read<UserConfigCubit>().state;
      if (userConfig != null && _memberDetailResponse?.member != null) {
        final config = UserConfig.fromMemberModel(
          member: _memberDetailResponse!.member,
          token: userConfig.token,
          firmUuid: userConfig.firmUuid,
        );
        await saveUserConfigToSharedPref(config);
      }
    } catch (e, stackTrace) {
      // Release logcat’ta da görülsün (parse/API hatası ayırt etmek için).
      debugPrint('[HamamExplore][dashboard] HATA: $e');
      debugPrint('$stackTrace');
    }
  }

  Future<void> getRoomSummary() async {
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;

      final hamamSpaUrl = HamamSpaUrlConstants.getOpenRoomSummaryUrl(
          externalApplicationConfig!.hamamspaApiUrl);
      final String token = await JwtStorageService.getToken() as String;
      var response = await RequestUtil.get(hamamSpaUrl, token: token);
      
      if (response == null || response.statusCode != 200) {
        print("Room summary fetch failed (offline or server error).");
        return;
      }
      
      final Map<String, dynamic> json = jsonDecode(response.body);

      setState(() {
        _openOrderModel = OpenOrderModel.fromJson(json["output"]);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadMemberData() async {
    try {
      await context.read<UserConfigCubit>().loadUserConfig();

      final userConfig = context.read<UserConfigCubit>().state;
      if (userConfig != null) {
        setState(() {
          final rawName = userConfig.name;

          _name = jsonDecode('"$rawName"');
          final String? thumbImageUrl = userConfig.thumbImageUrl;
          final String? imageUrl = userConfig.imageUrl;
          if (thumbImageUrl != null &&
              imageUrl != null &&
              imageUrl != "null" &&
              thumbImageUrl != "" &&
              imageUrl != "") {
            _imageProviderThumb = Image.network(thumbImageUrl).image;
            _imageProvider = Image.network(imageUrl).image;
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getSliderImages() async {
    try {
      var result = await getSliderScreenItems();
      var waitTime = await getSliderWaitTime();

      setState(() {
        for (var image in result!) {
          sliderImages.add(image);
        }
        _sliderWaitTime = waitTime;
      });
    } catch (e) {
      print(e);
    } finally {
      SliderImagesService.fetchAndStoreSliderImagesData(context);
    }
  }

  Future<void> _loadMobileAppSettings() async {
    if (_isFetchingMobileSettings) {
      return;
    }
    _isFetchingMobileSettings = true;

    try {
      final settingsCubit = context.read<MobileAppSettingsCubit>();
      if (settingsCubit.state == null) {
        await settingsCubit.loadFromCache();
      }

      var externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
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

      if (externalConfig == null) {
        return;
      }

      final apiUrl = externalConfig.apiHamamspaUrl;
      if (apiUrl.isEmpty) {
        return;
      }

      final token = await JwtStorageService.getToken();
      if (token == null || token.isEmpty) {
        return;
      }

      final result = await MobileAppSettingsService.fetchSettings(
          apiHamamSpaUrl: apiUrl, token: token);
      if (result == null) {
        return;
      }
      if (!mounted) {
        return;
      }

      final settings = result.settings;

      if (result.content.hasAnyContent) {
        context.read<AppContentCubit>().updateContent(result.content);
      }

      // Get current platform
      final currentPlatform = Platform.isIOS
          ? 'ios'
          : Platform.isAndroid
              ? 'android'
              : 'harmonyos';

      // Get current app version
      final info = await PackageInfo.fromPlatform();
      final currentAppVersion = info.version;

      // Get platform-based remote version from API
      final remoteVersion = settings.mobileAppVersions[currentPlatform] ?? '';

      print('=== Version Check Debug ===');
      print('Current Platform: $currentPlatform');
      print('Current App Version: $currentAppVersion');
      print('Remote Version (API): $remoteVersion');
      print('All Remote Versions: ${settings.mobileAppVersions}');

      // Get cached version for current platform
      final previousServerVersion =
          settingsCubit.getCachedVersion(currentPlatform);
      print('Previous Cached Version: $previousServerVersion');
      print('All Cached Versions: ${settingsCubit.state?.mobileAppVersions}');

      // Check if this is first install (cache is empty for this platform)
      final isFirstInstall =
          previousServerVersion == null || previousServerVersion.isEmpty;
      print('Is First Install: $isFirstInstall');

      // If first install and remote version exists, save to cache
      if (isFirstInstall && remoteVersion.isNotEmpty) {
        print(
            'First install detected - saving version to cache: $remoteVersion');
        // Cache will be updated by updateSettingsIfChanged, but we need to ensure it's saved
        await settingsCubit.updateSettingsIfChanged(settings);
        print('Version saved to cache');
        // Don't show prompt on first install - user just installed the app
        return;
      }

      // Check if version changed
      bool shouldPromptUpdate = false;

      if (remoteVersion.isNotEmpty &&
          previousServerVersion != null &&
          previousServerVersion.isNotEmpty) {
        print('Comparing versions: $previousServerVersion vs $remoteVersion');
        // Version changed - show prompt if version changed (regardless of current app version)
        // This allows server to control when users should update
        if (previousServerVersion != remoteVersion) {
          print(
              'Version changed detected! Previous: $previousServerVersion, New: $remoteVersion');
          shouldPromptUpdate = true;
          print('Should prompt update: $shouldPromptUpdate');
        } else {
          print('Versions are the same, no update needed');
        }
      } else {
        print(
            'Cannot check version: remoteVersion=$remoteVersion, previousServerVersion=$previousServerVersion');
      }

      // Update cache with new settings (always update cache, even if no prompt)
      await settingsCubit.updateSettingsIfChanged(settings);
      print('Cache updated');

      // Show update prompt if needed
      if (shouldPromptUpdate) {
        print('Showing update prompt...');
        await _maybeShowUpdatePrompt(settings, currentPlatform);
      }
      print('=== Version Check End ===');
    } catch (e) {
      // ignore errors silently, we can log if needed
      print('Mobile settings fetch error: $e');
    } finally {
      _isFetchingMobileSettings = false;
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    getDashboardData();
    loadMemberData();
    getSliderImages();
    getRoomSummary();
    _loadMobileAppSettings();
    _checkLatestAnnouncement();
  }

  Future<void> _checkLatestAnnouncement() async {
    try {
      final externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      if (externalConfig == null) {
        final storedExternal =
            await loadExternalApplicationsConfigFromSharedPref();
        if (storedExternal != null) {
          context
              .read<ExternalApplicationsConfigCubit>()
              .setExternalApplicationsConfig(storedExternal);
        }
      }

      final config = externalConfig ??
          context.read<ExternalApplicationsConfigCubit>().state;
      if (config == null) return;

      final apiUrl = config.apiHamamspaUrl;
      if (apiUrl.isEmpty) return;

      final token = await JwtStorageService.getToken();
      if (token == null || token.isEmpty) return;

      context.read<AnnouncementCubit>().checkLatestAnnouncement(
            apiHamamSpaUrl: apiUrl,
            token: token,
          );
    } catch (e) {
      print('Error checking latest announcement: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          SizedBox(
            height: 230,
            width: double.infinity,
            child: SvgPicture.asset(
              BlocTheme.theme.topBgSvgPath,
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                // Alt hizalama için
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: theme.panelPagePadding.left),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: Text(
                              labels.welcome,
                              maxLines: 1,
                              style:
                                  theme.textLabelBold(color: theme.default900Color),
                            ),
                          ),
                          SizedBox(height: theme.panelHomeBlockGap),
                          Flexible(
                            child: Text(
                              _name,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTitle(color: theme.default900Color),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: theme.panelPagePadding.right),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnnouncementIconWidget(),
                        const SizedBox(width: 12),
                        // Profil fotoğrafı
                        GestureDetector(
                          onTap: _imageProvider != null
                              ? () {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (_) => ImagePopupWidget(
                                      imageProvider: _imageProvider,
                                    ),
                                  );
                                }
                              : null,
                          child: _imageProvider != null
                              ? ClipOval(
                                  clipBehavior: Clip.antiAlias,
                                  child: Container(
                                    width: 55,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image(
                                      image: _imageProviderThumb!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : SvgPicture.asset(
                                  BlocTheme.theme.userSvgPath,
                                  fit: BoxFit.contain,
                                  width: 55,
                                  height: 55,
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: theme.panelHomeBlockGap,
              ),
              Row(
                children: [
                  Container(
                    margin: EdgeInsetsDirectional.fromSTEB(
                      theme.panelPagePadding.left,
                      0,
                      theme.panelPagePadding.right,
                      0,
                    ),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              spreadRadius: theme.panelListCardShadowSpread,
                              blurRadius: theme.panelListCardShadowBlur,
                              offset: Offset(0, theme.panelListCardShadowOffsetY),
                              color: theme.defaultBlackColor
                                  .withValues(alpha: theme.panelListCardShadowOpacity),
                            ),
                        ],
                        color: theme.defaultWhiteColor,
                        border: Border.all(color: theme.panelCardBorder),
                        borderRadius:
                            BorderRadius.circular(theme.panelLargeRadius)),
                    width: MediaQuery.sizeOf(context).width - 40,
                    height: 120,
                    child: Row(
                      children: [
                        BlocBuilder<ExternalApplicationsConfigCubit,
                            ExternalApplicationsConfig?>(
                          builder: (context, externalConfig) {
                            final potentialCustomerUrl =
                                externalConfig?.potentialCustomer ?? '';
                            final isPotentialCustomerEnabled =
                                potentialCustomerUrl.isNotEmpty;

                            return iconButtonWidget(
                                icon: BlocTheme.theme.inviteFriendSvgPath,
                                text: labels.inviteFriend,
                                onTap: isPotentialCustomerEnabled
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const InviteFriendScreen(),
                                          ),
                                        );
                                      }
                                    : () async {
                                        await warningDialog(
                                          context,
                                          message: labels.featureNotActive,
                                          path:
                                              BlocTheme.theme.attentionSvgPath,
                                          buttonColor:
                                              BlocTheme.theme.default500Color,
                                          buttonTextColor:
                                              BlocTheme.theme.defaultBlackColor,
                                        );
                                      },
                                margin:
                                    EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                                iconWidth: 45,
                                iconHeight: 40,
                                centerText: true);
                          },
                        ),
                        iconButtonWidget(
                            icon: BlocTheme.theme.walletSvgPath,
                            text: labels.virtualWallet,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const VirtualWalletScreen(),
                                ),
                              );
                            },
                            margin: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                            iconWidth: 45,
                            iconHeight: 40,
                            centerText: true),
                        iconButtonWidget(
                            icon: BlocTheme.theme.earnAsYouSpendSvgPath,
                            text: labels.earnAsYouSpend,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EarnAsYouSpendScreen(),
                                ),
                              );
                            },
                            margin:
                                EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                            iconWidth: 45,
                            iconHeight: 40,
                            centerText: true),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  spreadRadius: theme.panelListCardShadowSpread,
                                  blurRadius: theme.panelListCardShadowBlur,
                                  offset:
                                      Offset(0, theme.panelListCardShadowOffsetY),
                                  color: theme.defaultBlackColor.withValues(
                                      alpha: theme.panelListCardShadowOpacity),
                                ),
                              ],
                              color: theme.panelCardBackground,
                              border:
                                  Border.all(color: theme.panelCardBorder),
                              borderRadius:
                                  BorderRadius.circular(theme.panelLargeRadius),
                            ),
                            margin: EdgeInsetsDirectional.fromSTEB(
                                theme.panelPagePadding.left,
                                0,
                                theme.panelPagePadding.right,
                                0),
                            width: MediaQuery.sizeOf(context).width - 40,
                            height: 100,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const GymPackageHistory()));
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      // Tüm yazılar sol 20px içeride olacak şekilde padding ekledim
                                      padding: EdgeInsets.only(
                                          left: theme.panelPagePadding.left,
                                          right: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // 1. Satır - Abonelik Bilgileri
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10, bottom: 8),
                                            child: Text(
                                              labels.subscriptionInfo,
                                              softWrap: true,
                                              style: theme.panelTitleStyle,
                                            ),
                                          ),

                                          // 2. Satır - Kalan Gün Sayısı ile kutucuğu yan yana ve ortalı
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Visibility(
                                                visible: (_memberRegisterChartModel !=
                                                        null &&
                                                    (_memberRegisterChartModel!
                                                            .remainDays >
                                                        0)),
                                                child: Container(
                                                width: 16,
                                                height: 16,
                                                margin:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(0, 0, 10, 0),
                                                decoration: BoxDecoration(
                                                  color: BlocTheme
                                                      .theme.default900Color,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(3)),
                                                ),
                                              ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  (_memberRegisterChartModel !=
                                                              null &&
                                                          _memberRegisterChartModel!
                                                                  .remainDays >
                                                              0)
                                                      ? labels.remainingDays
                                                      : labels.noActiveMembership,
                                                  softWrap: false,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: (_memberRegisterChartModel !=
                                                              null &&
                                                          _memberRegisterChartModel!
                                                                  .remainDays >
                                                              0)
                                                      ? theme.textBody(
                                                          color: theme
                                                              .default900Color)
                                                      : theme.textCaption(
                                                          color: theme
                                                              .default900Color),
                                                ),
                                              )
                                            ],
                                          ),

                                          // Kalan Gün Sayısı ile Detaylı İncele arasında 14px boşluk
                                          const SizedBox(height: 5),

                                          // 3. Satır - Detaylı İncele, tabandan 8px yukarıda
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    labels.detailedView +
                                                        (_memberRegisterChartModel
                                                                    ?.isGymFrozen ==
                                                                true
                                                            ? ' ${labels.membershipFrozen}'
                                                            : ''),
                                                    softWrap: true,
                                                    style: theme
                                                        .textCaptionSemiBold(
                                                            color: theme
                                                                .defaultBlue800Color)
                                                        .copyWith(
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: Container(
                                  margin: const EdgeInsetsDirectional.fromSTEB(
                                      5, 3, 10, 3),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              SizedBox(
                                            width: 70,
                                            height: 70,
                                                child: PieChart(
                                                  PieChartData(
                                                    sectionsSpace: 0,
                                                    centerSpaceRadius: 25,
                                                    startDegreeOffset: -90,
                                                    sections: (_memberRegisterChartModel !=
                                                                    null &&
                                                                _memberRegisterChartModel!
                                                                        .totalGymRegisterDate >
                                                                    0)
                                                        ? [
                                                      PieChartSectionData(
                                                        value: _memberRegisterChartModel!
                                                            .remainDays,
                                                        color: theme
                                                            .chartAmberAccentColor,
                                                        showTitle: false,
                                                        radius:
                                                            theme.panelButtonRadius,
                                                      ),
                                                      PieChartSectionData(
                                                        value: _memberRegisterChartModel!
                                                                .totalGymRegisterDate -
                                                            _memberRegisterChartModel!
                                                                .remainDays,
                                                        color:
                                                            theme.default900Color,
                                                        showTitle: false,
                                                        radius:
                                                            theme.panelButtonRadius,
                                                            ),
                                                          ]
                                                        : [
                                                            PieChartSectionData(
                                                              value: 1,
                                                              color: theme
                                                                  .defaultGray300Color,
                                                              showTitle: false,
                                                              radius: theme
                                                                  .panelButtonRadius,
                                                      ),
                                                    ],
                                                    pieTouchData: PieTouchData(
                                                        enabled: false),
                                                  ),
                                                  swapAnimationDuration:
                                                      Duration.zero,
                                                ),
                                              ),
                                              Text(
                                                (_memberRegisterChartModel !=
                                                            null
                                                        ? _memberRegisterChartModel!
                                                            .remainDays
                                                            .toInt()
                                                        : 0)
                                                    .toString(),
                                                textAlign: TextAlign.center,
                                                style: theme.textBodyBold(
                                                    color: theme.default900Color),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: theme.panelHomeBlockGap,
                      ),
                      sliderImages.isNotEmpty
                          ? Row(
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                    spreadRadius: theme
                                                        .panelListCardShadowSpread,
                                                    blurRadius: theme
                                                        .panelListCardShadowBlur,
                                                    offset: Offset(
                                                        0,
                                                        theme
                                                            .panelListCardShadowOffsetY),
                                                    color: theme.defaultBlackColor
                                                        .withValues(
                                                            alpha: theme
                                                                .panelListCardShadowOpacity),
                                                  ),
                                              ],
                                              color: theme.defaultWhiteColor,
                                              border: Border.all(
                                                  color: theme.panelCardBorder),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      theme.panelLargeRadius)),
                                          margin:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  theme.panelPagePadding.left,
                                                  0,
                                                  theme.panelPagePadding.right,
                                                  0),
                                          width:
                                              MediaQuery.sizeOf(context).width -
                                                  40,
                                          height: 150,
                                          child: CarouselSlider(
                                            options: CarouselOptions(
                                              onPageChanged:
                                                  (position, reason) {},
                                              autoPlay: true,
                                              autoPlayInterval:
                                                  Duration(seconds: _sliderWaitTime),
                                              viewportFraction: 1.0,
                                              enlargeCenterPage: false,
                                            ),
                                            items:
                                                sliderImages.map<Widget>((i) {
                                              return Builder(
                                                builder:
                                                    (BuildContext context) {
                                                  return Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  theme.panelLargeRadius),
                                                          image: DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image:
                                                                  NetworkImage(
                                                                      i))));
                                                },
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              ],
                            )
                          : SizedBox.shrink(),
                      if (sliderImages.isNotEmpty)
                        SizedBox(
                          height: theme.panelHomeBlockGap,
                        ),
                      if (_openOrderModel?.roomName != null &&
                          _openOrderModel!.roomName.isNotEmpty)
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(25),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => MemberClosetQrScreen(
                                            //index: 2,
                                            //checkTime: false,
                                            )),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        spreadRadius:
                                            theme.panelListCardShadowSpread,
                                        blurRadius:
                                            theme.panelListCardShadowBlur,
                                        offset: Offset(
                                            0,
                                            theme.panelListCardShadowOffsetY),
                                        color: theme.defaultBlackColor.withValues(
                                            alpha: theme
                                                .panelListCardShadowOpacity),
                                      )
                                    ],
                                    color: theme.default500Color,
                                    border: Border.all(
                                      color: theme.panelCardBorder,
                                    ),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(theme.panelSectionSpacing +
                                            5)),
                                  ),
                                  margin: EdgeInsetsDirectional.fromSTEB(
                                      theme.panelPagePadding.left,
                                      12,
                                      theme.panelPagePadding.right,
                                      0),
                                  height: 50,
                                  child: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          BlocTheme.theme.doorSvgPath,
                                          width: 32,
                                          height: 32,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          _openOrderModel!.roomName,
                                          style: theme.textBodyBold(
                                              color: theme.default900Color),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: theme.panelHomeBlockGap,
                            ),
                          ],
                        ),
                      // Hızlı Erişim Bölümü
                      QuickAccessSectionWidget(
                        children: [
                                  Row(
                                    children: [
                                      iconButtonWidget(
                                          icon: BlocTheme
                                              .theme.fitnessProgrameSvgPath,
                                          text: labels.exerciseList,
                                          iconWidth: 45,
                                          iconHeight: 40,
                                          centerText: true,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const FitnessPrograme(),
                                              ),
                                            );
                                          },
                                          margin:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  10, 0, 0, 0)),
                                      iconButtonWidget(
                                          icon: BlocTheme
                                              .theme.measurementSvgPath,
                                          text: labels.measurementInfo,
                                          iconWidth: 45,
                                          iconHeight: 40,
                                          centerText: true,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const MeasurementHistory(),
                                              ),
                                            );
                                          },
                                          margin:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  10, 0, 0, 0)),
                                      iconButtonWidget(
                                          icon: BlocTheme
                                              .theme.personalTrainingSvgPath,
                                          text: labels.explorePtPackagesButtonLabel,
                                          iconWidth: 45,
                                          iconHeight: 40,
                                          centerText: true,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const PtPackageHistory(),
                                              ),
                                            );
                                          },
                                          margin:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  10, 0, 10, 0)),
                                    ],
                                  ),
                                  SizedBox(height: theme.panelHomeBlockGap),
                                  // İkinci 3 kutucuk (Beslenme, Grup Dersleri, Hızlı Randevu)
                                  Row(
                                    children: [
                                      iconButtonWidget(
                                          icon: BlocTheme.theme.dietSvgPath,
                                          text: labels.nutritionInfo,
                                          iconWidth: 45,
                                          iconHeight: 40,
                                          centerText: true,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const Diet(),
                                              ),
                                            );
                                          },
                                          margin:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  10, 0, 0, 0)),
                                      iconButtonWidget(
                                          icon: BlocTheme
                                              .theme.groupLessonSvgPath,
                                          text: labels.groupLessons,
                                          iconWidth: 45,
                                          iconHeight: 40,
                                          centerText: true,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const GroupLesson(),
                                              ),
                                            );
                                          },
                                          margin:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  10, 0, 0, 0)),
                                      iconButtonWidget(
                                          icon: BlocTheme
                                              .theme.resarvationNowSvgPath,
                                          text: labels.exploreQuickReservationButtonLabel,
                                          iconWidth: 45,
                                          iconHeight: 40,
                                          centerText: true,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const ResarvationNow(),
                                              ),
                                            );
                                          },
                                          margin:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  10, 0, 10, 0)),
                                    ],
                                  ),
                                  SizedBox(height: theme.panelHomeBlockGap),
                        ],
                      ),


                      Visibility(
                        visible: _openOrderModel != null,
                        child: Row(
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    final settings = context
                                        .read<MobileAppSettingsCubit>()
                                        .state;
                                    if (settings?.showRoomsAndLockers ??
                                        false) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ClosetSummary(),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              spreadRadius:
                                                  theme.panelListCardShadowSpread,
                                              blurRadius:
                                                  theme.panelListCardShadowBlur,
                                              offset: Offset(
                                                  0,
                                                  theme
                                                      .panelListCardShadowOffsetY),
                                              color: theme.defaultBlackColor
                                                  .withValues(
                                                      alpha: theme
                                                          .panelListCardShadowOpacity),
                                              ),
                                        ],
                                        color: theme.default500Color,
                                        border: Border.all(
                                            color: theme.default500Color),
                                        borderRadius: BorderRadius.circular(
                                            theme.panelLargeRadius)),
                                    margin: EdgeInsetsDirectional.fromSTEB(
                                        theme.panelPagePadding.left,
                                        12,
                                        theme.panelPagePadding.right,
                                        10),
                                    width:
                                        MediaQuery.sizeOf(context).width - 40,
                                    height: 98,
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 2,
                                            child: Container(
                                              margin: EdgeInsetsDirectional
                                                  .fromSTEB(20, 5, 10, 5),
                                              width: MediaQuery.sizeOf(context)
                                                  .width,
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5),
                                                      child: Text(
                                                        labels.facilityOccupancy,
                                                        textAlign:
                                                            TextAlign.left,
                                                        softWrap: true,
                                                        style: theme.textLabelBold(
                                                            color: theme
                                                                .defaultWhiteColor),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            theme.panelCompactInset),
                                                    if (_openOrderModel != null)
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Container(
                                                                width: 16,
                                                                height: 16,
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            10),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: BlocTheme
                                                                      .theme
                                                                      .default900Color,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: RichText(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  softWrap:
                                                                      true,
                                                                  text:
                                                                      TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text: labels.hamamExploreOccupancyPercentPart(
                                                                            _openOrderModel!
                                                                                .rate
                                                                                .toStringAsFixed(
                                                                                    0)),
                                                                        style:
                                                                            theme.textBody(color: theme.defaultWhiteColor),
                                                                      ),
                                                                      TextSpan(
                                                                        text: labels.hamamExploreOccupancyMembersPart(
                                                                            _openOrderModel!.open),
                                                                        style:
                                                                            theme.textCaption(color: theme.defaultWhiteColor),
                                                                      ),
                                                                     
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      )
                                                    else
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            width: 16,
                                                            height: 16,
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 10),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: BlocTheme
                                                                  .theme
                                                                  .default900Color,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              labels.noOccupancyData,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              softWrap: true,
                                                              style: theme.textBody(
                                                                  color: theme
                                                                      .defaultWhiteColor),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            )),
                                        Expanded(
                                            child: Container(
                                          margin:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  10, 3, 10, 3),
                                          width:
                                              MediaQuery.sizeOf(context).width,
                                          //color: Colors.blue,
                                          child: Column(
                                            children: [
                                              Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      SizedBox(
                                                        width: 90,
                                                        height: 90,
                                                        child: PieChart(
                                                          PieChartData(
                                                            sectionsSpace: 0,
                                                            centerSpaceRadius:
                                                                30,
                                                            startDegreeOffset:
                                                                -270,
                                                            sections: [
                                                              PieChartSectionData(
                                                                value: _openOrderModel
                                                                        ?.open
                                                                        .toDouble() ??
                                                                    0,
                                                                color: theme
                                                                    .defaultOrange400Color,
                                                                showTitle:
                                                                    false,
                                                                radius:
                                                                    theme.panelCardSpacing,
                                                              ),
                                                              PieChartSectionData(
                                                                value: ((_openOrderModel?.all ??
                                                                            0)
                                                                        .toDouble()) -
                                                                    ((_openOrderModel?.open ??
                                                                            0)
                                                                        .toDouble()),
                                                                color: theme.default900Color,
                                                                showTitle:
                                                                    false,
                                                                radius:
                                                                    theme.panelCardSpacing,
                                                              ),
                                                            ],
                                                            pieTouchData:
                                                                PieTouchData(
                                                                    enabled:
                                                                        false),
                                                          ),
                                                          swapAnimationDuration:
                                                              Duration.zero,
                                                        ),
                                                      ),
                                                      Text(
                                                        _openOrderModel != null
                                                            ? "%${_openOrderModel!.rate.toStringAsFixed(0)}"
                                                            : "%0",
                                                        style: theme.textBodyBold(
                                                            color: theme.default900Color),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        )),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Masaj Paket Bilgileri Bölümü
                      BlocBuilder<MobileAppSettingsCubit, MobileAppSettings?>(
                        builder: (context, settings) {
                          return Visibility(
                            visible: settings?.showMassagePackageInfo ?? true,
                            child: Row(children: [
                              Container(
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          spreadRadius:
                                              theme.panelListCardShadowSpread,
                                          blurRadius:
                                              theme.panelListCardShadowBlur,
                                          offset: Offset(
                                              0,
                                              theme.panelListCardShadowOffsetY),
                                          color: theme.defaultBlackColor
                                              .withValues(
                                                  alpha: theme
                                                      .panelListCardShadowOpacity),
                                        ),
                                    ],
                                    color: theme.panelCardBackground,
                                    border: Border.all(
                                        color: theme.panelCardBorder),
                                    borderRadius: BorderRadius.circular(
                                        theme.panelLargeRadius)),
                                margin: EdgeInsetsDirectional.fromSTEB(
                                    theme.panelPagePadding.left,
                                    2,
                                    theme.panelPagePadding.right,
                                    10),
                                width: MediaQuery.sizeOf(context).width - 40,
                                height: 66,
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 2,
                                        child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const MassagePackageHistory()));
                                            },
                                            child: Container(
                                              margin: EdgeInsetsDirectional
                                                  .fromSTEB(20, 10, 10, 5),
                                              width: MediaQuery.sizeOf(context)
                                                  .width,
                                              child: Column(
                                                children: [
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          textAlign:
                                                              TextAlign.left,
                                                          labels
                                                              .massagePackageDetailsCardTitle,
                                                          softWrap: true,
                                                          style: theme
                                                              .panelTitleStyle,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Expanded(
                                                            child: Text(
                                                          textAlign:
                                                              TextAlign.left,
                                                          labels.detailedView,
                                                          softWrap: true,
                                                          style: theme
                                                              .textCaptionSemiBold(
                                                                  color: theme
                                                                      .defaultBlue800Color)
                                                              .copyWith(
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                          ),
                                                        ))
                                                      ]),
                                                ],
                                              ),
                                            ))),
                                    Expanded(
                                        child: Container(
                                      margin: EdgeInsetsDirectional.fromSTEB(
                                          10, 0, 10, 0),
                                      width: MediaQuery.sizeOf(context).width,
                                      alignment: Alignment.centerRight,
                                      //color: Colors.blue,
                                      child: Column(
                                        children: [
                                          SvgPicture.asset(
                                            BlocTheme.theme.massageSvgPath,
                                            width: 55,
                                            height: 55,
                                            fit: BoxFit.contain,
                                          )
                                        ],
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            ]),
                          );
                        },
                      ),
                      // Kantin Bölümü
                      BlocBuilder<MobileAppSettingsCubit, MobileAppSettings?>(
                        builder: (context, settings) {
                          return Visibility(
                            visible: settings?.showKantinProducts ?? true,
                            child: SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    theme.panelPagePadding.left,
                                    0,
                                    0,
                                    theme.panelHomeBlockGap),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Başlık ve "Tüm Liste" satırı
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left:
                                                  10), // sadece 'Kantin' metni içeri kayar
                                          child: Text(
                                            labels.canteenSectionTitle,
                                            style: theme.textBodyBold(
                                                color: theme.default900Color),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            final category = CategoryModel
                                                .getCategories()[0];

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Product(
                                                  categoryUuid: category.uuid,
                                                  categoryName: category.name,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right:
                                                        0), // SAĞDAN 20px içeride
                                                child: Text(
                                                  labels.fullList,
                                                  style:
                                                      theme.textSmallSemiBold(
                                                          color: theme
                                                              .default900Color),
                                                ),
                                              ),
                                              SizedBox(width: theme.panelCompactInset - 2),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: theme.panelPagePadding.right +
                                                        5),
                                                child: SvgPicture.asset(
                                                  BlocTheme
                                                      .theme.arrowRightSvgPath,
                                                  width: 16,
                                                  height: 16,
                                                  color: BlocTheme
                                                      .theme.default900Color,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: theme.panelHomeBlockGap),
                                    SizedBox(
                                      height: 140,
                                      child: ListView.separated(
                                        padding: EdgeInsets.only(
                                            right: theme.panelPagePadding.right),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: CategoryModel.getCategories()
                                            .length,
                                        separatorBuilder: (_, __) =>
                                            SizedBox(width: theme.panelHomeBlockGap),
                                        itemBuilder: (context, index) {
                                          final category = CategoryModel
                                              .getCategories()[index];
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => Product(
                                                    categoryUuid: category.uuid,
                                                    categoryName: category.name,
                                                  ),
                                                ),
                                              );
                                              // detay yönlendirme
                                            },
                                            child: Container(
                                              width: 100,
                                              height: 90,
                                              padding: EdgeInsets.all(
                                                  theme.panelHomeBlockGap / 2),
                                              decoration: BoxDecoration(
                                                color: theme.panelCardBackground,
                                                border: Border.all(
                                                  color: theme.panelCardBorder,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        theme.panelButtonRadius),
                                              ),
                                              child: Stack(
                                                children: [
                                                  Align(
                                                    alignment: Alignment.center,
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        SizedBox(
                                                          width: 50,
                                                          height: 50,
                                                          child:
                                                              SvgPicture.asset(
                                                            category.image,
                                                            width: 32,
                                                            height: 32,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height: theme
                                                                .panelCompactInset),
                                                        Text(
                                                          category.name,
                                                          textAlign:
                                                              TextAlign.center,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 2,
                                                          style: theme
                                                              .textSmallSemiBold(
                                                                  color: theme
                                                                      .default900Color),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 1,
                                                    right: 0,
                                                    child: Icon(
                                                      Icons.arrow_forward,
                                                      size: theme
                                                              .panelRowIconSizeSmall +
                                                          1,
                                                      color: theme.default900Color,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _maybeShowUpdatePrompt(
      MobileAppSettings settings, String platform) async {
    try {
      final remoteVersion = settings.mobileAppVersions[platform] ?? '';

      if (remoteVersion.isEmpty) {
        if (kDebugMode) {
          debugPrint(
              '_maybeShowUpdatePrompt: Remote version is empty, skipping');
        }
        return;
      }

      // Get platform-specific URL
      final targetUrl = settings.mobileAppUrls[platform] ?? '';
      final parsedUri = Uri.tryParse(targetUrl);
      final isValidUrl = parsedUri != null &&
          parsedUri.isAbsolute &&
          (parsedUri.scheme == 'https' || parsedUri.scheme == 'http') &&
          parsedUri.hasAuthority;

      if (kDebugMode) {
        debugPrint(
            '_maybeShowUpdatePrompt: Remote version=$remoteVersion, URL=$targetUrl, isValidUrl=$isValidUrl');
      }

      if (!mounted) return;
      final theme = BlocTheme.theme;
      final labels = AppLabels.current;
      await warningDialog(
        context,
        message: labels.newVersionPromptWithTarget(remoteVersion),
        buttonColor: theme.default500Color,
        buttonTextColor: theme.defaultWhiteColor,
        secondaryButtonColor: theme.defaultRed700Color,
        secondaryButtonTextColor: theme.defaultWhiteColor,
        primaryButtonText: labels.update,
        secondaryButtonText: labels.close,
        onPrimaryPressed: () async {
          if (isValidUrl) {
            await launchUrl(parsedUri, mode: LaunchMode.externalApplication);
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Version prompt error: $e');
      }
    }
  }
}
