import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:e_sport_life/config/ability/mobile_ability_cubit.dart';
import 'package:e_sport_life/config/app-config/app_config_cubit.dart';
import 'package:e_sport_life/config/app-content/app_content_cubit.dart';
import 'package:e_sport_life/config/external-applications-config/external_applications_config.dart';
import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/config/user-config/user_config.dart';
import 'package:e_sport_life/config/user-config/user_config_cubit.dart';
import 'package:e_sport_life/contants/application_constant.dart';
import 'package:e_sport_life/core/constants/url/api_hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/constants/url/system_api_url_constants.dart';
import 'package:e_sport_life/core/enums/application_type.dart';
import 'package:e_sport_life/core/enums/mobile_user_type.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/utils/shared-preferences/locale_cache_utils.dart';
import 'package:e_sport_life/core/services/device_uuid_storage_service.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/utils/internet_connection_utils.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/utils/response_utils.dart';
import 'package:e_sport_life/core/utils/shared-preferences/external_applications_config_utils.dart';
import 'package:e_sport_life/core/utils/shared-preferences/user_config_utils.dart';
import 'package:e_sport_life/core/widgets/show_no_internet_dialog_widget.dart';
import 'package:e_sport_life/core/widgets/warning_dialog_widget.dart';
import 'package:e_sport_life/screen/panel/common/tabs/tabs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SecurityCodeScreen extends StatefulWidget {
  const SecurityCodeScreen({Key? key}) : super(key: key);

  static String get id => AppLabels.current.verificationCode;

  @override
  State<SecurityCodeScreen> createState() => _SecurityCodeScreenState();
}

class _SecurityCodeScreenState extends State<SecurityCodeScreen> {
  final myController = TextEditingController();
  late FocusNode myFocusNode;
  bool _passwordVisibility = true;

  static Future<bool> useToken(BuildContext context, String code) async {
    try {
      String url = SystemApiUrlConstants.getUseTokenUrl(code);

      final response = await RequestUtil.get(url);
      var result = extractOutputIfFound(response!.body);
      if (result != null) {
        var d = result;

        var data = json.decode(result["data"]);
        ApplicationConstant.setApplicationId(d["application_id"].toString());
        ApplicationConstant.setFirmId(d["firm_id"].toString());
        ApplicationConstant.setHamamSpaApiUrl(data["hamamspa_api_url"]);
        ApplicationConstant.setKantincimApiUrl(data["kantincim"]);
        ApplicationConstant.setGymTrainingApiUrl(data["gym_training"]);
        ApplicationConstant.setRandevuAlApiUrl(data["online_resarvation"]);
        ApplicationConstant.setDigitalSignageApiUrl(data["digital_signage"]);
        ApplicationConstant.setHost(data["host"]);
        ApplicationConstant.setMemberId(data["member_id"].toString());
        ApplicationConstant.setName(data["name"].toString());
        ApplicationConstant.setPhone(data["phone"].toString());
        ApplicationConstant.setBirthday(data["birthday"].toString());
        ApplicationConstant.setGender(data["gender"].toString());
        ApplicationConstant.setToken(data["token"].toString());
        ApplicationConstant.setImageUrl(data["image_url"].toString());
        ApplicationConstant.setThumbImageUrl(
            data["thumb_image_url"].toString());
        ApplicationConstant.setSecurityKey(d["security_code"].toString());

        var jsonData = data;
        JwtStorageService.saveToken(data["token"]);
        final config = UserConfig.fromMap(jsonData);
        await saveUserConfigToSharedPref(config);

        final externalApplicationConfigData =
            ExternalApplicationsConfig.fromMap(jsonData);
        await saveExternalApplicationsConfigToSharedPref(
            externalApplicationConfigData);

        context.read<UserConfigCubit>().updateUserConfig(config);
        context
            .read<ExternalApplicationsConfigCubit>()
            .updateExternalApplicationsConfig(externalApplicationConfigData);

        final savedLocale = await LocaleCacheUtils.load();
        AppLabels.init(config.applicationType, locale: savedLocale);

        if (config.userType != MobileUserType.member) {
          await _fetchAndLoadAbilities(context, data["token"], data["hamamspa_api_url"]);
        }

        return true;
      } else {
        return false;
      }
    } on TimeoutException {
      rethrow;
    } on SocketException {
      rethrow;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _fetchAndLoadAbilities(
      BuildContext context, String token, String apiUrl) async {
    try {
      final url = ApiHamamSpaUrlConstants.getMyAbilitiesUrl(apiUrl);
      final result = await RequestUtil.getJson(url, token: token);
      if (result.isSuccess) {
        await context
            .read<MobileAbilityCubit>()
            .loadFromApi(result.outputList ?? []);
      }
    } catch (_) {
      // Ability fetch failed; non-blocking
    }
  }

  bool _submit = false;
  bool _result = false;
  bool _isValidating = false;
  bool _kvkkAccepted = false;
  String _kvkkContent = '';

  void _onKvkkTapped() {
    if (_kvkkAccepted) {
      setState(() {
        _kvkkAccepted = false;
      });
    } else {
      _showKvkkDialog();
    }
  }

  Future<void> _showKvkkDialog() async {
    bool hasReachedEnd = false;
    final ScrollController controller = ScrollController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!hasReachedEnd &&
                  controller.hasClients &&
                  controller.position.maxScrollExtent <= 0) {
                setStateDialog(() {
                  hasReachedEnd = true;
                });
              }
            });

            return AlertDialog(
              backgroundColor:
                  Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(AppLabels.current.kvkkTitle),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                width: double.maxFinite,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (!hasReachedEnd &&
                        notification.metrics.pixels >=
                            notification.metrics.maxScrollExtent) {
                      setStateDialog(() {
                        hasReachedEnd = true;
                      });
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    controller: controller,
                    child: Text(
                      _kvkkContent,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: BlocTheme.theme.defaultRed700Color,
                  ),
                  child: Text(AppLabels.current.cancel),
                ),
                TextButton(
                  onPressed: hasReachedEnd
                      ? () {
                          Navigator.pop(dialogContext);
                          setState(() {
                            _kvkkAccepted = true;
                          });
                        }
                      : null,
                  style: TextButton.styleFrom(
                    foregroundColor: hasReachedEnd
                        ? BlocTheme.theme.default700Color
                        : Theme.of(context).disabledColor,
                  ),
                  child: Text(AppLabels.current.approve),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
  }

  Widget _buildKvkkConsentRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: GestureDetector(
              onTap: _onKvkkTapped,
              child: Text(
                AppLabels.current.kvkkRead,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14,
                  color: BlocTheme.theme.defaultGray900Color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _onKvkkTapped,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _kvkkAccepted
                    ? BlocTheme.theme.default700Color
                    : Colors.transparent,
                border: Border.all(
                  color: BlocTheme.theme.default700Color,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: _kvkkAccepted
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
    _loadKvkkContent();
  }

  Future<void> _loadKvkkContent() async {
    final cubitContent = context.read<AppContentCubit>().state;
    if (cubitContent?.kvkk?.content != null) {
      setState(() => _kvkkContent = cubitContent!.kvkk!.content!);
      return;
    }

    try {
      final kvkkString =
          await rootBundle.loadString('assets/config/kvkk.json');
      final kvkkJson = json.decode(kvkkString);
      setState(() {
        _kvkkContent = kvkkJson['content'] ?? '';
      });
    } catch (e) {
      setState(() {
        _kvkkContent = AppLabels.current.kvkkLoadError;
      });
    }
  }

  @override
  void dispose() {
    myController.dispose();
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
final size = MediaQuery.of(context).size;
final isTablet = size.shortestSide >= 600;

    return Scaffold(
      appBar: null,
      body: Container(
        padding: EdgeInsets.zero,
        child: BlocBuilder<AppConfigCubit, AppConfigState>(
          builder: (context, configState) {
            return BlocBuilder<BlocTheme, ThemeData>(
              builder: (context, themeData) {
                return SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.sizeOf(context).height,
                    ),
                    decoration: BoxDecoration(
                      color: BlocTheme.theme.defaultBackgroundColor,
                      image: DecorationImage(
                        fit: BoxFit.contain,
                        alignment: AlignmentDirectional(0, -1),
                        image: Image.asset(
                          'assets/images/application_images/verification_screen_bg.png',
                        ).image,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                          SizedBox(height: MediaQuery.of(context).padding.top),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: MediaQuery.sizeOf(context).width,
                                height:
                                    (isTablet == true ? MediaQuery.sizeOf(context).height * 0.754 : MediaQuery.sizeOf(context).height * 0.454),
                                decoration: BoxDecoration(),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: MediaQuery.sizeOf(context).width,
                                                decoration: const BoxDecoration(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Align(
                                      alignment: AlignmentDirectional(1, 1),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                            child: Align(
                                              alignment:
                                                  AlignmentDirectional(-1, -1),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(20, 10, 0, 0),
                                                child: Text(
                                                  configState.welcomeMessage,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      fontFamily: BlocTheme.theme.fontFamily,
                                                      letterSpacing: 0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: BlocTheme.theme
                                                          .defaultGrayColor,
                                                      fontSize: 24),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Expanded(
                                          child: Align(
                                            alignment:
                                                AlignmentDirectional(-1, 0),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(20, 10, 0, 0),
                                              child: Text(
                                                configState.appDisplayName,
                                                maxLines: 1,
                                                style: TextStyle(
                                                    fontFamily: BlocTheme.theme.fontFamily,
                                                    letterSpacing: 0,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 42,
                                                    color: BlocTheme
                                                        .theme.default500Color),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (_isValidating == false)
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: AlignmentDirectional(-1, 0),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          20, 0, 0, 0),
                                      child: Text(
                                        AppLabels.current.enterVerificationCode,
                                        style: TextStyle(
                                            fontFamily: BlocTheme.theme.fontFamily,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: BlocTheme
                                                .theme.default500Color),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (_isValidating == false)
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        10, 20, 10, 0),
                                    child: TextFormField(
                                      controller: myController,
                                      focusNode: myFocusNode,
                                      autofocus: false,
                                      obscureText: _passwordVisibility,
                                      decoration: InputDecoration(
                                        labelText:
                                            AppLabels.current.verificationCodeHint,
                                        labelStyle: TextStyle(
                                            fontFamily: BlocTheme.theme.fontFamily,
                                            letterSpacing: 0,
                                            color: BlocTheme
                                                .theme.defaultGray900Color),
                                        alignLabelWithHint: true,
                                        hintStyle: TextStyle(
                                            fontFamily: BlocTheme.theme.fontFamily,
                                            letterSpacing: 2,
                                            fontWeight: FontWeight.normal,
                                            color: BlocTheme
                                                .theme.defaultGray700Color),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: BlocTheme
                                                .theme.defaultGray700Color,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: BlocTheme
                                                .theme.defaultGray700Color,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: BlocTheme.theme.defaultRed700Color,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: BlocTheme.theme.defaultRed700Color,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        prefixIcon: Icon(
                                          Icons.lock_outlined,
                                          color:
                                              BlocTheme.theme.default500Color,
                                        ),
                                        suffixIcon: InkWell(
                                          onTap: () => setState(
                                            () => _passwordVisibility =
                                                !_passwordVisibility,
                                          ),
                                          focusNode:
                                              FocusNode(skipTraversal: true),
                                          child: Icon(
                                            _passwordVisibility
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: BlocTheme
                                                .theme.defaultGray900Color,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                      style: TextStyle(
                                          fontFamily: BlocTheme.theme.fontFamily,
                                          letterSpacing: 5,
                                          color: BlocTheme
                                              .theme.defaultGray900Color),
                                      maxLength: 6,
                                      maxLengthEnforcement:
                                          MaxLengthEnforcement.enforced,
                                      keyboardType: TextInputType.number,
                                      cursorColor:
                                          BlocTheme.theme.defaultGray900Color,
                                      onChanged: (text) {
                                        setState(() {
                                          _submit = (text.characters.length == 6
                                              ? true
                                              : false);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          _buildKvkkConsentRow(),
                          _submit == true && _isValidating == false
                              ? Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            10, 10, 10, 0),
                                        child: ElevatedButton(
                                          onPressed: _submit == false
                                              ? null
                                              : () async {
                                                  if (!_kvkkAccepted) {
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            AppLabels.current.kvkkApprovalRequired),
                                                      ),
                                                    );
                                                    return;
                                                  }

                                                  setState(() {
                                                    _isValidating = true;
                                                  });
                                                  await Future.delayed(
                                                      const Duration(seconds: 2));
                                                  _result =
                                                      await InternetConnectionUtil
                                                          .checkInternetConnection();
                                                  if (_result == true) {
                                                    try {
                                                      _result = await useToken(
                                                          context, myController.text);
                                                      if (_result == true) {
                                                        await _registerDevice();
                                                        _isValidating = false;
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                const Tabs(index: 0),
                                                          ),
                                                        );
                                                      } else {
                                                        await warningDialog(context,
                                                            message:
                                                                AppLabels.current.verificationCodeError);
                                                        setState(() {
                                                          _submit = false;
                                                          _isValidating = false;
                                                        });
                                                        myController.text = '';
                                                      }
                                                    } on TimeoutException {
                                                      await warningDialog(context,
                                                          message:
                                                              AppLabels.current.serverUnreachable);
                                                      setState(() {
                                                        _submit = false;
                                                        _isValidating = false;
                                                      });
                                                      myController.text = '';
                                                    } on SocketException {
                                                      await warningDialog(context,
                                                          message:
                                                              AppLabels.current.serverUnreachable);
                                                      setState(() {
                                                        _submit = false;
                                                        _isValidating = false;
                                                      });
                                                      myController.text = '';
                                                    }
                                                  } else {
                                                    setState(() {
                                                      _submit = false;
                                                      _isValidating = false;
                                                    });
                                                    await showNoInternetDialog(
                                                        context);
                                                    myController.text = '';
                                                  }
                                                },
                                          child: Text(
                                            AppLabels.current.login,
                                            style: TextStyle(
                                              color: BlocTheme.theme
                                                  .defaultGray900Color,
                                              fontSize: 18,
                                              fontFamily: BlocTheme.theme.fontFamily,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: BlocTheme.theme.defaultBlackColor,
                                            backgroundColor:
                                                BlocTheme.theme.default500Color,
                                            textStyle: TextStyle(
                                                fontFamily: BlocTheme.theme.fontFamily,
                                                letterSpacing: 0,
                                                fontSize: 18,
                                                color: BlocTheme
                                                    .theme.defaultGray900Color,
                                                fontWeight: FontWeight.bold),
                                            elevation: 3,
                                            minimumSize: Size(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.9,
                                                50),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              : Row(),
                          if (_isValidating) SizedBox(height: 50),
                          if (_isValidating)
                            CircularProgressIndicator(
                                color: BlocTheme.theme.default500Color),
                          if (_isValidating) SizedBox(height: 50),
                          if (_isValidating)
                            Text(AppLabels.current.codeValidating,
                                maxLines: 1,
                                style: TextStyle(
                                    fontFamily: BlocTheme.theme.fontFamily,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w600,
                                    color: BlocTheme.theme.defaultGrayColor,
                                    fontSize: 18)),
                          // Bottom padding to ensure button is accessible on all devices
                          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                        ],
                      ),
                    ),
                  );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _registerDevice() async {
    try {
      final externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      if (externalConfig == null) {
        return;
      }
      final hamamSpaUrl = externalConfig.apiHamamspaUrl;
      if (hamamSpaUrl.isEmpty) {
        return;
      }

      final registerUrl =
          ApiHamamSpaUrlConstants.getDeviceRegisterUrl(hamamSpaUrl);
      final token = await JwtStorageService.getToken();
      if (token == null || token.isEmpty) {
        return;
      }

      final response = await RequestUtil.post(
        registerUrl,
        token: token,
        body: const {},
      );

      if (response != null && response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        final output = jsonMap['output'];
        if (output is Map<String, dynamic>) {
          final uuid = output['device_uuid'];
          if (uuid is String && uuid.isNotEmpty) {
            await DeviceUuidStorageService.saveDeviceUuid(uuid);
          }
        }
      }
    } catch (_) {
      // Non-blocking: device registration failure shouldn't prevent app usage
    }
  }
}
