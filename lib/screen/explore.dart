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
import 'package:e_sport_life/core/constants/url/hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/data/model/category_model.dart';
import 'package:e_sport_life/data/model/open_order_model.dart';
import 'package:e_sport_life/screen/panel/common/announcement/announcements_list_screen.dart';
import 'package:e_sport_life/screen/closet-screen/closet_summary_screen.dart';
import 'package:e_sport_life/screen/diet-screen/diet_screen.dart';
import 'package:e_sport_life/screen/group-lesson-screen/group_lesson_screen.dart';
import 'package:e_sport_life/screen/panel/member/invite-friend/invite_friend_screen.dart';
import 'package:e_sport_life/screen/measurement-screen/measurement_history_screen.dart';
import 'package:e_sport_life/screen/product-screen/products_screen.dart';
import 'package:e_sport_life/screen/panel/member/qr-code/member_closet_qr_screen.dart';
import 'package:e_sport_life/screen/resarvation-now-screen/resarvation_now_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/user-config/user_config.dart';
import '../config/user-config/user_config_cubit.dart';
import '../contants/application_color.dart';
import '../core/services/mobile_app_settings_service.dart';
import '../core/services/slider_images_service.dart';
import '../core/utils/shared-preferences/external_applications_config_utils.dart';
import '../core/utils/shared-preferences/member_status_utils.dart';
import '../core/utils/shared-preferences/slider_utils.dart';
import '../core/utils/shared-preferences/user_config_utils.dart';
import '../core/widgets/icon_button_widget.dart';
import '../core/widgets/image_popup_widget.dart';
import '../core/widgets/warning_dialog_widget.dart';
import '../data/model/member_detail_response_model.dart';
import '../data/model/member_register_chart_model.dart';
import './package-screen/gym_history_screen.dart';
import './package-screen/massage_package_history_screen.dart';
import './package-screen/pt_package_history_screen.dart';
import 'fitness-programe-screen/fitness_programe_screen.dart';
import 'earn-as-you-spend-screen/earn_as_you_spend_screen.dart';
import 'virtual-wallet-screen/virtual_wallet_screen.dart';

class Explore extends StatefulWidget {
  const Explore({Key? key}) : super(key: key);

  static const String id = "Anasayfa";
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
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;

      final hamamSpaUrl = HamamSpaUrlConstants.getMemberDashboardDataUrl(
          externalApplicationConfig!.hamamspaApiUrl);
      final String token = await JwtStorageService.getToken() as String;
      var response = await RequestUtil.get(hamamSpaUrl, token: token);
      
      if (response == null || response.statusCode != 200) {
        print("Dashboard data fetch failed (offline or server error).");
        return;
      }
      
      final Map<String, dynamic> json = jsonDecode(response.body);
      final memberDetail = MemberDetailResponse.fromJson(json);

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
    } catch (e) {
      print(e);
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
          final rawName = userConfig?.name ?? '';

          _name = jsonDecode('"$rawName"');
          final String? thumbImageUrl = userConfig?.thumbImageUrl;
          final String? imageUrl = userConfig?.imageUrl;
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
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 30), // Buraya ekledik
                            child: Text(
                              "Hoş Geldiniz",
                              maxLines: 1,
                              style: TextStyle(
                                fontFamily: "Inter",
                                letterSpacing: 0,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Flexible(
                            child: Text(
                              _name,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: "Inter",
                                letterSpacing: 0,
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Announcement ikonu
                        BlocBuilder<AnnouncementCubit, AnnouncementState>(
                          builder: (context, announcementState) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AnnouncementsListScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: BlocTheme.theme.default300Color,
                                  shape: BoxShape.circle,
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Center(
                                      child: SvgPicture.asset(
                                        BlocTheme.theme.annoucementSvgPath,
                                        width: 24,
                                        height: 24,
                                        fit: BoxFit.contain,
                                        /*colorFilter: ColorFilter.mode(
                                          Colors.white,
                                          BlendMode.srcIn,
                                        ),*/
                                      ),
                                    ),
                                    if (announcementState.hasNewAnnouncement)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          width: 11,
                                          height: 11,
                                          decoration: BoxDecoration(
                                            color: BlocTheme
                                                .theme.defaultRed700Color,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
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
                height: 10,
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              spreadRadius: 1,
                              color: Color.fromARGB(
                                1,
                                249,
                                250,
                                251,
                              ))
                        ],
                        color: Colors.white,
                        border:
                            Border.all(color: Color.fromARGB(1, 249, 250, 251)),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
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
                                text: "Arkadaşını \n Davet Et",
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
                                          message:
                                              'Bu özellik şuanda aktif değil',
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
                            text: "Sanal \n Cüzdan",
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
                            text: "Harcadıkça \n Kazan",
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
                                  spreadRadius: 1,
                                  color: const Color.fromARGB(1, 249, 250, 251),
                                ),
                              ],
                              color: ApplicationColor.primaryBoxBackground,
                              border: Border.all(
                                  color:
                                      const Color.fromARGB(1, 249, 250, 251)),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                            ),
                            margin: const EdgeInsetsDirectional.fromSTEB(
                                20, 0, 20, 0),
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
                                      padding: const EdgeInsets.only(
                                          left: 20, right: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // 1. Satır - Abonelik Bilgileri
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10, bottom: 8),
                                            child: Text(
                                              "Abonelik Bilgileri",
                                              softWrap: true,
                                              style: TextStyle(
                                                color:
                                                    ApplicationColor.fourthText,
                                                fontFamily: "Inter",
                                                letterSpacing: 0,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18,
                                              ),
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
                                                      ? "Kalan Gün Sayısı"
                                                      : "Aktif Fitness Üyeliğiniz Bulunmamaktadır",
                                                  softWrap: false,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: BlocTheme
                                                      .theme.default900Color,
                                                  fontFamily: "Inter",
                                                  letterSpacing: 0,
                                                  fontWeight: FontWeight.w500,
                                                    fontSize: (_memberRegisterChartModel !=
                                                                null &&
                                                            _memberRegisterChartModel!
                                                                    .remainDays >
                                                                0)
                                                        ? 16
                                                        : 12,
                                                  ),
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
                                                    "Detaylı İncele" +
                                                        (_memberRegisterChartModel
                                                                    ?.isGymFrozen ==
                                                                true
                                                            ? " (Üyelik Donduruldu)"
                                                            : ""),
                                                    softWrap: true,
                                                    style: TextStyle(
                                                      decoration: TextDecoration
                                                          .underline,
                                                      color: BlocTheme.theme
                                                          .defaultBlue800Color,
                                                      fontFamily: "Inter",
                                                      letterSpacing: 0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
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
                                                        value: _memberRegisterChartModel
                                                                ?.remainDays
                                                                ?.toDouble() ??
                                                            0,
                                                        color: const Color(
                                                            0xFFFBBF24),
                                                        showTitle: false,
                                                              radius: 10,
                                                      ),
                                                      PieChartSectionData(
                                                        value: (_memberRegisterChartModel
                                                                    ?.totalGymRegisterDate ??
                                                                0) -
                                                            (_memberRegisterChartModel
                                                                    ?.remainDays ??
                                                                0),
                                                        color: const Color(
                                                            0xFF375000),
                                                        showTitle: false,
                                                              radius: 10,
                                                            ),
                                                          ]
                                                        : [
                                                            PieChartSectionData(
                                                              value: 1,
                                                              color: BlocTheme
                                                                  .theme
                                                                  .defaultGray300Color,
                                                              showTitle: false,
                                                              radius: 10,
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
                                                (_memberRegisterChartModel
                                                                ?.remainDays
                                                                ?.toInt() ??
                                                            0)
                                                        .toString(),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontFamily: "Inter",
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Color.fromARGB(
                                                      255, 55, 80, 0),
                                                ),
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
                        height: 10,
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
                                                    spreadRadius: 1,
                                                    color: Color.fromARGB(
                                                      1,
                                                      249,
                                                      250,
                                                      251,
                                                    ))
                                              ],
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Color.fromARGB(
                                                      1, 249, 250, 251)),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20))),
                                          margin:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  20, 0, 20, 0),
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
                                                          borderRadius: BorderRadius.circular(20),
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
                          height: 10,
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
                                        spreadRadius: 1,
                                        color: const Color.fromARGB(
                                            1, 249, 250, 251),
                                      )
                                    ],
                                    color: BlocTheme.theme.default500Color,
                                    border: Border.all(
                                      color: const Color.fromARGB(
                                          1, 249, 250, 251),
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(25)),
                                  ),
                                  margin: const EdgeInsetsDirectional.fromSTEB(
                                      20, 12, 20, 0),
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
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                BlocTheme.theme.default900Color,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      // Hızlı Erişim Bölümü
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsetsDirectional.fromSTEB(
                                20, 0, 20, 0),
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      offset: const Offset(1, 2),
                                      blurRadius: 8,
                                      spreadRadius: 0,
                                      color:
                                          const Color.fromRGBO(0, 0, 0, 0.15))
                                ],
                                color: Colors.white,
                                border: Border.all(
                                    color: BlocTheme.theme.defaultGray300Color,
                                    width: 1),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20))),
                            width: MediaQuery.sizeOf(context).width - 40,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Hızlı Erişim Başlığı
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, top: 0, bottom: 10),
                                    child: Text(
                                      "Hızlı Erişim",
                                      style: TextStyle(
                                        color: BlocTheme.theme.default900Color,
                                        fontFamily: "Inter",
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // İlk 3 kutucuk (Egzersiz, Ölçüm, Personal Training)
                                  Row(
                                    children: [
                                      iconButtonWidget(
                                          icon: BlocTheme
                                              .theme.fitnessProgrameSvgPath,
                                          text: "Egzersiz \n Listem",
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
                                          text: "Ölçüm \n Bilgilerim",
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
                                          text: "Personal \n Training",
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
                                  const SizedBox(height: 10),
                                  // İkinci 3 kutucuk (Beslenme, Grup Dersleri, Hızlı Randevu)
                                  Row(
                                    children: [
                                      iconButtonWidget(
                                          icon: BlocTheme.theme.dietSvgPath,
                                          text: "Beslenme \n Bilgilerim",
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
                                          text: "Grup \n Dersleri",
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
                                          text: "Hızlı \n Randevu",
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
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),


                      Visibility(
                        visible: _openOrderModel != null &&
                            _openOrderModel!.open != null &&
                            _openOrderModel!.all != null &&
                            _openOrderModel!.rate != null,
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
                                              spreadRadius: 1,
                                              color: Color.fromARGB(
                                                1,
                                                249,
                                                250,
                                                251,
                                              ))
                                        ],
                                        color: ApplicationColor.primary,
                                        border: Border.all(
                                            color: ApplicationColor.primary),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    margin: EdgeInsetsDirectional.fromSTEB(
                                        20, 12, 20, 10),
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
                                                        "Tesis Doluluk Oranı",
                                                        textAlign:
                                                            TextAlign.left,
                                                        softWrap: true,
                                                        style: TextStyle(
                                                          color: BlocTheme.theme
                                                              .defaultWhiteColor,
                                                          fontFamily: "Inter",
                                                          letterSpacing: 0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
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
                                                                        text:
                                                                            "%${_openOrderModel!.rate.toStringAsFixed(0)} Doluluk ",
                                                                        style:
                                                                            TextStyle(
                                                                          color: BlocTheme
                                                                              .theme
                                                                              .defaultWhiteColor,
                                                                          fontFamily:
                                                                              "Inter",
                                                                          letterSpacing:
                                                                              0,
                                                                          fontWeight:
                                                                              FontWeight
                                                                                  .w500,
                                                                          fontSize:
                                                                              16,
                                                                        ),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            "(${_openOrderModel!.open} Üye)",
                                                                        style:
                                                                            TextStyle(
                                                                          color: BlocTheme
                                                                              .theme
                                                                              .defaultWhiteColor,
                                                                          fontFamily:
                                                                              "Inter",
                                                                          letterSpacing:
                                                                              0,
                                                                          fontWeight:
                                                                              FontWeight
                                                                                  .w500,
                                                                          fontSize:
                                                                              12,
                                                                        ),
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
                                                              "Doluluk Bilgisi Yok",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              softWrap: true,
                                                              style: TextStyle(
                                                                color: BlocTheme
                                                                    .theme
                                                                    .defaultWhiteColor,
                                                                fontFamily:
                                                                    "Inter",
                                                                letterSpacing:
                                                                    0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 16,
                                                              ),
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
                                                                color: BlocTheme
                                                                    .theme
                                                                    .defaultOrange400Color, // Dolu bölüm: FBBF24
                                                                showTitle:
                                                                    false,
                                                                radius: 15,
                                                              ),
                                                              PieChartSectionData(
                                                                value: ((_openOrderModel?.all ??
                                                                            0)
                                                                        .toDouble()) -
                                                                    ((_openOrderModel?.open ??
                                                                            0)
                                                                        .toDouble()),
                                                                color: const Color(
                                                                    0xFF375000), // Boş bölüm: 375000
                                                                showTitle:
                                                                    false,
                                                                radius: 15,
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
                                                        style: const TextStyle(
                                                          fontFamily: "Inter",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                          color: Color.fromARGB(
                                                              255, 55, 80, 0),
                                                        ),
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
                                          spreadRadius: 1,
                                          color: Color.fromARGB(
                                            1,
                                            249,
                                            250,
                                            251,
                                          ))
                                    ],
                                    color:
                                        ApplicationColor.primaryBoxBackground,
                                    border: Border.all(
                                        color:
                                            Color.fromARGB(1, 249, 250, 251)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                margin: EdgeInsetsDirectional.fromSTEB(
                                    20, 2, 20, 10),
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
                                                          "Masaj Paket Bilgileri",
                                                          softWrap: true,
                                                          style: TextStyle(
                                                              color: BlocTheme
                                                                  .theme
                                                                  .default900Color,
                                                              fontFamily:
                                                                  "Inter",
                                                              letterSpacing: 0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18),
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
                                                          "Detaylı İncele",
                                                          softWrap: true,
                                                          style: TextStyle(
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                              color: BlocTheme
                                                                  .theme
                                                                  .defaultBlue800Color,
                                                              fontFamily:
                                                                  "Inter",
                                                              letterSpacing: 0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12),
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
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    20, 0, 0, 10),
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
                                            "Kantin",
                                            style: TextStyle(
                                              color: BlocTheme
                                                  .theme.default900Color,
                                              fontFamily: "Inter",
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
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
                                                  "Tüm Liste",
                                                  style: TextStyle(
                                                    color: BlocTheme
                                                        .theme.default900Color,
                                                    fontFamily: "Inter",
                                                    letterSpacing: 0,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 25),
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
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      height: 140,
                                      child: ListView.separated(
                                        padding: const EdgeInsets.only(
                                            right:
                                                20), // SAĞDAN 20px BOŞLUK EKLENDİ
                                        scrollDirection: Axis.horizontal,
                                        itemCount: CategoryModel.getCategories()
                                            .length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(width: 10),
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
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                color: ApplicationColor
                                                    .primaryBoxBackground,
                                                border: Border.all(
                                                  color: const Color.fromARGB(
                                                      1, 249, 250, 251),
                                                ),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10)),
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
                                                        const SizedBox(
                                                            height: 8),
                                                        Text(
                                                          category.name,
                                                          textAlign:
                                                              TextAlign.center,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            color: BlocTheme
                                                                .theme
                                                                .default900Color,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 1,
                                                    right: 0,
                                                    child: Icon(
                                                      Icons.arrow_forward,
                                                      size: 21,
                                                      color: BlocTheme.theme
                                                          .default900Color,
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

  // Compare two version strings (e.g., "3.0.3" vs "2.0.2")
  // Returns: 1 if version1 > version2, -1 if version1 < version2, 0 if equal
  int _compareVersions(String version1, String version2) {
    final parts1 =
        version1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final parts2 =
        version2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // Pad shorter version with zeros
    while (parts1.length < parts2.length) parts1.add(0);
    while (parts2.length < parts1.length) parts2.add(0);

    for (int i = 0; i < parts1.length; i++) {
      if (parts1[i] > parts2[i]) return 1;
      if (parts1[i] < parts2[i]) return -1;
    }
    return 0;
  }

  Future<void> _maybeShowUpdatePrompt(
      MobileAppSettings settings, String platform) async {
    try {
      final remoteVersion = settings.mobileAppVersions[platform] ?? '';

      if (remoteVersion.isEmpty) {
        print('_maybeShowUpdatePrompt: Remote version is empty, skipping');
        return;
      }

      // Get platform-specific URL
      final targetUrl = settings.mobileAppUrls[platform] ?? '';
      final parsedUri = Uri.tryParse(targetUrl);
      final isValidUrl = parsedUri != null &&
          parsedUri.isAbsolute &&
          (parsedUri.scheme == 'https' || parsedUri.scheme == 'http') &&
          parsedUri.hasAuthority;

      print(
          '_maybeShowUpdatePrompt: Remote version=$remoteVersion, URL=$targetUrl, isValidUrl=$isValidUrl');

      if (!mounted) return;
      await warningDialog(
        context,
        message:
            'Yeni bir sürüm mevcut. Uygulamayı ${remoteVersion} sürümüne güncellemek ister misiniz?',
        buttonColor: BlocTheme.theme.default500Color,
        buttonTextColor: Colors.white,
        secondaryButtonColor: BlocTheme.theme.defaultRed700Color,
        secondaryButtonTextColor: Colors.white,
        primaryButtonText: 'Güncelle',
        secondaryButtonText: 'Kapat',
        onPrimaryPressed: () async {
          if (isValidUrl) {
            await launchUrl(parsedUri!, mode: LaunchMode.externalApplication);
          }
        },
      );
    } catch (e) {
      print('Version prompt error: $e');
    }
  }
}
