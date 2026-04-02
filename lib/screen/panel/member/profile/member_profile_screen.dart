import 'dart:convert';

import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/mobile-app-settings/mobile_app_settings.dart';
import 'package:e_sport_life/config/mobile-app-settings/mobile_app_settings_cubit.dart';
import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/config/user-config/user_config_cubit.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/member_service.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/services/email_verification_service.dart';
import 'package:e_sport_life/core/utils/jwt_utils.dart';
import 'package:e_sport_life/core/utils/shared-preferences/external_applications_config_utils.dart';
import 'package:e_sport_life/core/utils/shared-preferences/email_verification_cache_utils.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/exit_app_dialog_widget.dart';
import 'package:e_sport_life/core/widgets/image_popup_widget.dart';
import 'package:e_sport_life/core/widgets/profile_photo_update_dialog_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/core/widgets/warning_dialog_widget.dart';
import 'package:e_sport_life/screen/panel/common/security-code/security_code_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:intl/intl.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

// Custom formatter for birthday input (dd/MM/yyyy)
class _BirthdayInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    // Remove all non-digit characters
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // If empty, return as is
    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    // Build formatted string with slashes
    String formatted = '';
    for (int i = 0; i < digitsOnly.length && i < 8; i++) {
      if (i == 2 || i == 4) {
        formatted += '/';
      }
      formatted += digitsOnly[i];
    }
    
    // Calculate cursor position - preserve cursor relative to end
    int cursorPosition = formatted.length;
    final oldDigitsOnly = oldValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length < oldDigitsOnly.length) {
      // Backspace was pressed - try to preserve position
      final deletedChars = oldDigitsOnly.length - digitsOnly.length;
      cursorPosition = (newValue.selection.baseOffset - deletedChars).clamp(0, formatted.length);
    } else {
      // Character was added
      cursorPosition = formatted.length;
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

class MemberProfile extends StatefulWidget {
  const MemberProfile({Key? key}) : super(key: key);

  static const String id = "Üye Profili";

  @override
  State<MemberProfile> createState() => _MemberProfileState();
}

class _MemberProfileState extends State<MemberProfile> {
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _genderController = new TextEditingController();
  TextEditingController _birthdayController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  ImageProvider? _imageProvider = null;
  int? _selectedGender; // 0: Erkek, 1: Kadın
  bool _isSaving = false; // Loading state for save operation
  bool _showEmailVerificationLink = false; // Show email verification link
  bool _isSendingEmailVerification = false; // Loading state for email verification

  //AssetImage('assets/images/application_images/profile.png');

  final myController = TextEditingController();
  late FocusNode myFocusNode;

  Future<void> getProfileData() async {
    try {
      final userConfig = context.read<UserConfigCubit>().state;
      
      // Get email from JWT
      String? jwtEmail;
      String? emailVerifiedAt;
      final token = await JwtStorageService.getToken();
      if (token != null) {
        jwtEmail = JwtUtils.getUserEmail(token);
        emailVerifiedAt = JwtUtils.getEmailVerifiedAt(token);
      }
      
      // Check if we should show verification link
      final verificationRequested = await EmailVerificationCacheUtils.isVerificationRequested();
      // Get email value to check if it's not empty
      final emailValue = jwtEmail ?? userConfig!.email.toString();
      final shouldShowLink = !verificationRequested && 
          (emailVerifiedAt == null || emailVerifiedAt.isEmpty) &&
          (emailValue.isNotEmpty);
      
      setState(() {
        _passwordController.text = userConfig!.memberId.toString();
        var name = userConfig!.name.toString();
        _nameController.text = jsonDecode('"$name"');
        if (userConfig!.gender == 0) {
          _genderController.text = AppLabels.current.male;
          _selectedGender = 0;
        } else if (userConfig!.gender == 1) {
          _genderController.text = AppLabels.current.female;
          _selectedGender = 1;
        } else {
          _genderController.text = "";
          _selectedGender = null;
        }

        _birthdayController.text = userConfig!.birthday.toString();
        if (userConfig!.imageUrl != null &&
            userConfig!.imageUrl != "" &&
            userConfig!.imageUrl != "null") {
          _imageProvider = Image.network(userConfig!.imageUrl.toString()).image;
        }

        _phoneController.text = userConfig!.phone.toString();
        // Use JWT email if available, otherwise fallback to userConfig email
        _emailController.text = emailValue;
        _selectedGender = userConfig!.gender;
        _showEmailVerificationLink = shouldShowLink;
      });
    } catch (e) {
      print(e);
    }
  }
  
  Future<void> _handleEmailVerificationResend() async {
    if (_isSendingEmailVerification) return; // Prevent multiple clicks
    
    setState(() {
      _isSendingEmailVerification = true;
    });
    
    try {
      final token = await JwtStorageService.getToken();
      if (token == null) {
        if (mounted) {
          setState(() {
            _isSendingEmailVerification = false;
          });
          await warningDialog(
            context,
            message: AppLabels.current.sessionNotFoundReLogin,
          );
        }
        return;
      }

      final success = await EmailVerificationService.resendEmailVerification(
        token: token,
      );

      if (success) {
        // Mark as requested in cache
        await EmailVerificationCacheUtils.setVerificationRequested();
        
        if (mounted) {
          setState(() {
            _showEmailVerificationLink = false;
            _isSendingEmailVerification = false;
          });
          
          await warningDialog(
            context,
            message: AppLabels.current.emailVerificationSent,
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _isSendingEmailVerification = false;
          });
          await warningDialog(
            context,
            message: AppLabels.current.emailVerificationFailed,
          );
        }
      }
    } catch (e) {
      print('Email verification resend error: $e');
      if (mounted) {
        setState(() {
          _isSendingEmailVerification = false;
        });
        await warningDialog(
          context,
          message: AppLabels.current.emailVerificationFailed,
        );
      }
    }
  }

  Future<void> _handlePhotoUpdate() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ProfilePhotoUpdateDialogWidget(
        currentImage: _imageProvider,
      ),
    );

    if (result != null && mounted) {
      print('Photo update result: $result');
      final userConfig = context.read<UserConfigCubit>().state;
      if (userConfig != null) {
        // Check if photo was deleted
        final isDeleted = result['deleted'] == true || result['deleted'] == 'true';
        print('Is deleted: $isDeleted');
        
        if (isDeleted) {
          print('Deleting photo from UI');
          final updatedConfig = userConfig.copyWith(
            imageUrl: '',
            thumbImageUrl: '',
          );
          context.read<UserConfigCubit>().updateUserConfig(updatedConfig);
          setState(() {
            _imageProvider = null;
          });
          print('Photo deleted from UI, _imageProvider is now null');
        } else {
          final imageUrl = result['image_url']?.toString() ?? '';
          final thumbImageUrl = result['thumb_image_url']?.toString() ?? '';
          
          if (imageUrl.isNotEmpty) {
            final updatedConfig = userConfig.copyWith(
              imageUrl: imageUrl,
              thumbImageUrl: thumbImageUrl,
            );
            context.read<UserConfigCubit>().updateUserConfig(updatedConfig);
            setState(() {
              _imageProvider = Image.network(imageUrl).image;
            });
          }
        }
      }
    }
  }

  Future<void> _saveMemberInfo() async {
    if (!mounted || _isSaving) return;

    // Validate token
    final token = await JwtStorageService.getToken();
      if (token == null || token.isEmpty) {
      Navigator.of(context).pop();
      await JwtStorageService.deleteToken();
      await warningDialog(
        context,
        message: AppLabels.current.sessionNotFoundReLogin,
      );
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SecurityCodeScreen()),
          (route) => false,
        );
      }
      return;
    }

    // Get API URL
    var externalConfig = context.read<ExternalApplicationsConfigCubit>().state;
    if (externalConfig == null) {
      final storedExternal = await loadExternalApplicationsConfigFromSharedPref();
      if (storedExternal != null) {
        context
            .read<ExternalApplicationsConfigCubit>()
            .updateExternalApplicationsConfig(storedExternal);
        externalConfig = storedExternal;
      }
    }

    if (externalConfig == null || externalConfig.hamamspaApiUrl.isEmpty) {
      if (mounted) {
        await warningDialog(
          context,
          message: AppLabels.current.apiConnectionNotFound,
        );
      }
      return;
    }

    final apiUrl = externalConfig.hamamspaApiUrl;

    // Set saving state
    if (mounted) {
      setState(() {
        _isSaving = true;
      });
    }

    try {
      // Call API to update member info
      final result = await MemberService.updateMemberInfo(
        apiHamamSpaUrl: apiUrl,
        token: token,
        name: _nameController.text,
        gender: _selectedGender ?? 0,
        birthday: _birthdayController.text,
      );

      if (result != null && mounted) {
        // Update local UserConfig with the response
        final userConfig = context.read<UserConfigCubit>().state;
        if (userConfig != null) {
          final updatedConfig = userConfig.copyWith(
            name: _nameController.text,
            gender: _selectedGender ?? userConfig.gender,
            birthday: _birthdayController.text,
          );
          context.read<UserConfigCubit>().updateUserConfig(updatedConfig);
        }

        // Show success dialog
        if (mounted) {
          await warningDialog(
            context,
            message: AppLabels.current.profileUpdateSuccess,
          );
        }
      } else {
        // Show error message
        if (mounted) {
          await warningDialog(
            context,
            message: AppLabels.current.profileUpdateFailed,
          );
        }
      }
    } catch (e) {
      print('Error updating member info: $e');
      if (mounted) {
        await warningDialog(
          context,
            message: '${AppLabels.current.profileUpdateFailed}: ${e.toString()}',
        );
      }
    } finally {
      // Reset saving state
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getProfileData();
    myFocusNode = FocusNode();
    // Load mobile app settings from cache if not loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsCubit = context.read<MobileAppSettingsCubit>();
      if (settingsCubit.state == null) {
        settingsCubit.loadFromCache();
      }
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: TopAppBarWidget(
          title: AppLabels.current.myProfile,
        ),
        body: Container(
          margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20),
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 2,
                  blurStyle: BlurStyle.outer,
                  color: BlocTheme.theme.defaultBlackColor,
                  offset: Offset.zero,
                  spreadRadius: 1,
                )
              ],
              borderRadius: BorderRadius.all(Radius.circular(20))),
          padding: const EdgeInsets.all(10.0),
          height: MediaQuery.sizeOf(context).height -
              (MediaQuery.sizeOf(context).height * 0.22),
          child: new ListView(
            reverse: true,
            children: <Widget>[
              Container(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: BlocBuilder<MobileAppSettingsCubit,
                              MobileAppSettings?>(
                            builder: (context, settings) {
                              final canUpdatePhoto =
                                  settings?.allowProfilePhotoUpdate == true;

                              return Center(
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: [
                                    // Profile photo or SVG
                                    _imageProvider != null
                                        ? GestureDetector(
                                            onTap: () async {
                                              if (canUpdatePhoto) {
                                                await _handlePhotoUpdate();
                                              } else {
                                                // Show image popup if update is disabled
                                        showDialog(
                                            context: context,
                                            barrierDismissible: true,
                                                    builder: (_) =>
                                                        ImagePopupWidget(
                                                            imageProvider:
                                                                _imageProvider));
                                              }
                                            },
                                            child: ClipOval(
                                              child: Image(
                                                image: _imageProvider!,
                                                width: 120,
                                                height: 120,
                                                fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : SvgPicture.asset(
                                  BlocTheme.theme.userSvgPath,
                                  fit: BoxFit.contain,
                                            width: 120,
                                            height: 120,
                                          ),
                                    // Edit icon (only if update is enabled)
                                    if (canUpdatePhoto)
                                      Positioned(
                                        top: 80,
                                        right: -5,
                                        child: GestureDetector(
                                          onTap: () async {
                                            await _handlePhotoUpdate();
                                          },
                                          child: Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              color: BlocTheme
                                                  .theme.default100Color,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: BlocTheme
                                                    .theme.default900Color,
                                                width: 1,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.edit,
                                              color: BlocTheme
                                                  .theme.default500Color,
                                              size: 20,
                                            ),
                                          ),
                                ),
                        ),
                      ],
                    ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    // Name field - editable if allowMemberInfoUpdate is true
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: BlocBuilder<MobileAppSettingsCubit, MobileAppSettings?>(
                            builder: (context, settings) {
                              final canEdit = settings?.allowMemberInfoUpdate == true;
                              
                              return Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(10, 20, 10, 0),
                            child: TextFormField(
                                  readOnly: !canEdit,
                              controller: _nameController,
                              focusNode: myFocusNode,
                              autofocus: false,
                                  inputFormatters: [
                                    UpperCaseTextFormatter(),
                                  ],
                              decoration: InputDecoration(
                                labelText: AppLabels.current.fullName,
                                labelStyle: TextStyle(
                                    fontFamily: BlocTheme.theme.fontFamily,
                                    letterSpacing: 0,
                                    color: BlocTheme.theme.defaultBlackColor),
                                alignLabelWithHint: true,
                                hintStyle: TextStyle(
                                    fontFamily: BlocTheme.theme.fontFamily,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.normal,
                                    color: BlocTheme.theme.defaultGray500Color),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: BlocTheme.theme.defaultBlackColor,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: BlocTheme.theme.defaultBlackColor,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                        color: BlocTheme.theme.defaultRed700Color,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: BlocTheme.theme.defaultRed700Color,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              style: TextStyle(
                                  fontFamily: BlocTheme.theme.fontFamily, letterSpacing: 0),
                              maxLength: 100,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                                  cursorColor: BlocTheme.theme.defaultBlackColor,
                              onChanged: (text) {
                                setState(() {});
                              },
                            ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(10, 10, 10, 0),
                            child: TextFormField(
                              readOnly: true,
                              inputFormatters: [
                                new MaskTextInputFormatter(
                                    mask: '+# (###) ###-##-##',
                                    filter: {"#": RegExp(r'[0-9]')},
                                    type: MaskAutoCompletionType.lazy)
                              ],
                              controller: _phoneController,
                              autofocus: false,
                              decoration: InputDecoration(
                                labelText: AppLabels.current.phoneNumber,
                                labelStyle: TextStyle(
                                    fontFamily: BlocTheme.theme.fontFamily,
                                    letterSpacing: 0,
                                    color: BlocTheme.theme.defaultBlackColor),
                                alignLabelWithHint: true,
                                hintStyle: TextStyle(
                                    fontFamily: BlocTheme.theme.fontFamily,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.normal,
                                    color: BlocTheme.theme.defaultGray500Color),
                                filled: true,
                                fillColor: Colors.grey[200],
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey[400]!,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey[400]!,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: BlocTheme.theme.defaultRed700Color,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: BlocTheme.theme.defaultRed700Color,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              style: TextStyle(
                                  fontFamily: BlocTheme.theme.fontFamily, 
                                  letterSpacing: 0,
                                  color: Colors.grey[700]),
                              maxLength: 100,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              cursorColor: BlocTheme.theme.defaultBlackColor,
                              onChanged: (text) {
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Email input (read-only)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(10, 10, 10, 0),
                                child: TextFormField(
                                  readOnly: true,
                                  controller: _emailController,
                                  autofocus: false,
                                  decoration: InputDecoration(
                                    labelText: AppLabels.current.email,
                                    labelStyle: TextStyle(
                                        fontFamily: BlocTheme.theme.fontFamily,
                                        letterSpacing: 0,
                                        color: BlocTheme.theme.defaultBlackColor),
                                    alignLabelWithHint: true,
                                    hintStyle: TextStyle(
                                        fontFamily: BlocTheme.theme.fontFamily,
                                        letterSpacing: 2,
                                        fontWeight: FontWeight.normal,
                                        color: BlocTheme.theme.defaultGray500Color),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: Colors.grey[600],
                                      size: 20,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey[400]!,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey[400]!,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: BlocTheme.theme.defaultRed700Color,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: BlocTheme.theme.defaultRed700Color,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  style: TextStyle(
                                      fontFamily: BlocTheme.theme.fontFamily, 
                                      letterSpacing: 0,
                                      color: Colors.grey[700]),
                                  maxLength: 100,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  cursorColor: BlocTheme.theme.defaultBlackColor,
                                  onChanged: (text) {
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Email verification link
                        if (_showEmailVerificationLink)
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(10, 5, 20, 0),
                            child: Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: GestureDetector(
                                onTap: _isSendingEmailVerification ? null : _handleEmailVerificationResend,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    // Text genişliğini ölç
                                    final textStyle = TextStyle(
                                      fontFamily: BlocTheme.theme.fontFamily,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    );
                                    final textSpan = TextSpan(
                                      text:                                             AppLabels.current.confirmEmail,
                                              style: textStyle,
                                    );
                                    final textPainter = TextPainter(
                                      text: textSpan,
                                      textDirection: Directionality.of(context),
                                    );
                                    textPainter.layout();
                                    final textWidth = textPainter.size.width;
                                    final textHeight = textPainter.size.height;
                                    
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            if (_isSendingEmailVerification)
                                              SizedBox(
                                                width: textHeight,
                                                height: textHeight,
                                                child: Padding(
                                                  padding: EdgeInsets.only(right: 8),
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      BlocTheme.theme.default500Color,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            Text(
                                              AppLabels.current.confirmEmail,
                                              style: TextStyle(
                                                fontFamily: BlocTheme.theme.fontFamily,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: _isSendingEmailVerification
                                                    ? BlocTheme.theme.default500Color.withOpacity(0.6)
                                                    : BlocTheme.theme.default500Color,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 3),
                                        Container(
                                          width: textWidth + 4, // 2px sağ + 2px sol
                                          height: 1,
                                          color: BlocTheme.theme.default500Color,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    // Gender - dropdown when editable, read-only when not
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: BlocBuilder<MobileAppSettingsCubit, MobileAppSettings?>(
                            builder: (context, settings) {
                              final canEdit = settings?.allowMemberInfoUpdate == true;
                              
                              return Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(10, 10, 10, 0),
                                child: canEdit
                                    ? DropdownButtonFormField<int>(
                                        value: _selectedGender,
                                        decoration: InputDecoration(
                                          labelText: AppLabels.current.gender,
                                          labelStyle: TextStyle(
                                              fontFamily: BlocTheme.theme.fontFamily,
                                              letterSpacing: 0,
                                              color: BlocTheme.theme.defaultBlackColor),
                                          alignLabelWithHint: true,
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: BlocTheme.theme.defaultBlackColor,
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: BlocTheme.theme.defaultBlackColor,
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: BlocTheme.theme.defaultRed700Color,
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          focusedErrorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: BlocTheme.theme.defaultRed700Color,
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                        ),
                                        dropdownColor: Colors.white,
                                        style: TextStyle(
                                          fontFamily: BlocTheme.theme.fontFamily,
                                          letterSpacing: 0,
                                          color: BlocTheme.theme.defaultBlackColor,
                                        ),
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: BlocTheme.theme.defaultBlackColor,
                                        ),
                                        iconEnabledColor: BlocTheme.theme.defaultBlackColor,
                                        items: [
                                          DropdownMenuItem<int>(
                                            value: 0,
                                            child: Text(
                                              AppLabels.current.male,
                                              style: TextStyle(
                                                fontFamily: BlocTheme.theme.fontFamily,
                                                color: BlocTheme.theme.defaultBlackColor,
                                              ),
                                            ),
                                          ),
                                          DropdownMenuItem<int>(
                                            value: 1,
                                            child: Text(
                                              AppLabels.current.female,
                                              style: TextStyle(
                                                fontFamily: BlocTheme.theme.fontFamily,
                                                color: BlocTheme.theme.defaultBlackColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedGender = value;
                                            _genderController.text = value == 0 ? AppLabels.current.male : AppLabels.current.female;
                                          });
                                        },
                                      )
                                    : TextFormField(
                              readOnly: true,
                                        controller: _genderController,
                              autofocus: false,
                                        decoration: InputDecoration(
                                          labelText: AppLabels.current.gender,
                                          labelStyle: TextStyle(
                                              fontFamily: BlocTheme.theme.fontFamily,
                                              letterSpacing: 0,
                                              color: BlocTheme.theme.defaultBlackColor),
                                          alignLabelWithHint: true,
                                          hintStyle: TextStyle(
                                              fontFamily: BlocTheme.theme.fontFamily,
                                              letterSpacing: 2,
                                              fontWeight: FontWeight.normal,
                                              color: BlocTheme.theme.defaultGray500Color),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: BlocTheme.theme.defaultBlackColor,
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: BlocTheme.theme.defaultBlackColor,
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: BlocTheme.theme.defaultRed700Color,
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          focusedErrorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: BlocTheme.theme.defaultRed700Color,
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                        ),
                                        style: TextStyle(
                                            fontFamily: BlocTheme.theme.fontFamily, 
                                            letterSpacing: 0,
                                            color: BlocTheme.theme.defaultBlackColor),
                                      ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    // Birthday field - editable if allowMemberInfoUpdate is true
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: BlocBuilder<MobileAppSettingsCubit, MobileAppSettings?>(
                            builder: (context, settings) {
                              final canEdit = settings?.allowMemberInfoUpdate == true;
                              
                              return Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(10, 20, 10, 0),
                                child: TextFormField(
                                  readOnly: !canEdit,
                                  controller: _birthdayController,
                                  autofocus: false,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: canEdit ? [
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                                    LengthLimitingTextInputFormatter(10),
                                    _BirthdayInputFormatter(),
                                  ] : null,
                              decoration: InputDecoration(
                                    prefixIcon: canEdit ? InkWell(
                                      onTap: () async {
                                        // Parse existing date if available
                                        DateTime? initialDate;
                                        if (_birthdayController.text.isNotEmpty) {
                                          try {
                                            // Try parsing dd/MM/yyyy format
                                            final parts = _birthdayController.text.split('/');
                                            if (parts.length == 3 && parts[0].isNotEmpty && parts[1].isNotEmpty && parts[2].isNotEmpty) {
                                              initialDate = DateTime(
                                                int.parse(parts[2]),
                                                int.parse(parts[1]),
                                                int.parse(parts[0]),
                                              );
                                            }
                                          } catch (e) {
                                            // If parsing fails, use default date
                                            initialDate = DateTime.now().subtract(Duration(days: 365 * 18)); // Default to 18 years ago
                                          }
                                        } else {
                                          initialDate = DateTime.now().subtract(Duration(days: 365 * 18)); // Default to 18 years ago
                                        }

                                        final DateTime? picked = await showDatePicker(
                                          context: context,
                                          initialDate: initialDate ?? DateTime.now().subtract(Duration(days: 365 * 18)),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime.now(),
                                          locale: const Locale('tr', 'TR'),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                textButtonTheme: TextButtonThemeData(
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: BlocTheme.theme.default600Color,
                                                  ),
                                                ),
                                                colorScheme: Theme.of(context).colorScheme.copyWith(
                                                  primary: BlocTheme.theme.default600Color,
                                                ),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );

                                        if (picked != null) {
                                          final formattedDate = DateFormat('dd/MM/yyyy').format(picked);
                                          setState(() {
                                            _birthdayController.text = formattedDate;
                                          });
                                        }
                                      },
                                      child: Icon(
                                  Icons.cake_outlined,
                                        color: BlocTheme.theme.defaultBlackColor,
                                ),
                                    ) : Icon(
                                      Icons.cake_outlined,
                                      color: BlocTheme.theme.defaultBlackColor,
                                    ),
                                labelText: AppLabels.current.birthDate,
                                labelStyle: TextStyle(
                                    fontFamily: BlocTheme.theme.fontFamily,
                                    letterSpacing: 0,
                                    color: BlocTheme.theme.defaultBlackColor),
                                alignLabelWithHint: true,
                                    hintText: AppLabels.current.birthDateFormat,
                                hintStyle: TextStyle(
                                    fontFamily: BlocTheme.theme.fontFamily,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.normal,
                                    color: BlocTheme.theme.defaultGray500Color),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: BlocTheme.theme.defaultBlackColor,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: BlocTheme.theme.defaultBlackColor,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                        color: BlocTheme.theme.defaultRed700Color,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: BlocTheme.theme.defaultRed700Color,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              style: TextStyle(
                                  fontFamily: BlocTheme.theme.fontFamily, letterSpacing: 0),
                                  maxLength: 10,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                                  cursorColor: BlocTheme.theme.defaultBlackColor,
                                  onChanged: canEdit ? (text) {
                                setState(() {});
                                  } : null,
                                ),
                              );
                              },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(10, 10, 10, 0),
                            child: TextFormField(
                              readOnly: true,
                              controller: _passwordController,
                              autofocus: false,
                              decoration: InputDecoration(
                                labelText: AppLabels.current.lockerPassword,
                                labelStyle: TextStyle(
                                    fontFamily: BlocTheme.theme.fontFamily,
                                    letterSpacing: 0,
                                    color: BlocTheme.theme.defaultBlackColor),
                                alignLabelWithHint: true,
                                hintStyle: TextStyle(
                                    fontFamily: BlocTheme.theme.fontFamily,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.normal,
                                    color: BlocTheme.theme.defaultGray500Color),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: BlocTheme.theme.defaultBlackColor,
                                    //FlutterFlowTheme.of(context).primaryText,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: BlocTheme.theme.defaultBlackColor,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: BlocTheme.theme.defaultRed700Color,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: BlocTheme.theme.defaultRed700Color,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              style: TextStyle(
                                  fontFamily: BlocTheme.theme.fontFamily, letterSpacing: 0),
                              maxLength: 6,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              cursorColor: BlocTheme.theme.defaultBlackColor,
                              onChanged: (text) {
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    /*Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "Bildirimleri Almak İstiyorum",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: BlocTheme.theme.defaultBlackColor,
                              fontFamily: BlocTheme.theme.fontFamily,
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: 0.75, // 0.5 ile 1.0 arasında oynayabilirsin
                          child: Switch(
                            value: _notificationsEnabled,
                            onChanged: (bool value) {
                              setState(() {
                                _notificationsEnabled = value;
                              });
                            },
                            activeColor: BlocTheme.theme.default500Color,
                          ),
                        ),
                      ],
                    ),*/
                    // Save and Logout buttons - side by side
                    BlocBuilder<MobileAppSettingsCubit, MobileAppSettings?>(
                      builder: (context, settings) {
                        final canEdit = settings?.allowMemberInfoUpdate == true;
                        
                        return Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(10, 10, 10, 0),
                          child: Row(
                      children: [
                              // Save button (only shown if allowMemberInfoUpdate is true)
                              if (canEdit) ...[
                        Expanded(
                            child: ElevatedButton(
                                    onPressed: _isSaving ? null : () async {
                                      await _saveMemberInfo();
                                    },
                              style: ElevatedButton.styleFrom(
                                      backgroundColor: BlocTheme.theme.default500Color,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      disabledBackgroundColor: BlocTheme.theme.default500Color.withOpacity(0.6),
                                    ),
                                    child: _isSaving
                                        ? Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                              ),
                            ),
                          ),
                                              SizedBox(width: 8),
                                              Text(
                                                AppLabels.current.saving,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: BlocTheme.theme.fontFamily,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            AppLabels.current.save,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: BlocTheme.theme.fontFamily,
                                              color: BlocTheme.theme.defaultBlackColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(width: 12),
                              ],
                              // Logout button
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : () async {
                                    await logoutAppDialog(
                                      context,
                                      message: AppLabels.current.logoutConfirm,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    AppLabels.current.logout,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: BlocTheme.theme.fontFamily,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ].reversed.toList(),
          ),
        ),
        bottomNavigationBar: BottomNavigationBarWidget(
          tab: NavTab.profile,
        ));
  }
}
