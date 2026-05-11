import 'dart:convert';

import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/config/user-config/user_config_cubit.dart';
import 'package:e_sport_life/core/utils/profession_keys_sort_utils.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/trainer_profile_service.dart';
import 'package:e_sport_life/core/utils/shared-preferences/email_verification_cache_utils.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/color_picker_dialog_widget.dart';
import 'package:e_sport_life/core/widgets/email_change_dialog_widget.dart';
import 'package:e_sport_life/core/widgets/password_change_dialog_widget.dart';
import 'package:e_sport_life/core/widgets/phone_change_dialog_widget.dart';
import 'package:e_sport_life/core/widgets/profile_language_selector_widget.dart';
import 'package:e_sport_life/core/widgets/profile_photo_update_dialog_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/core/widgets/exit_app_dialog_widget.dart';
import 'package:e_sport_life/core/widgets/warning_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class _BirthdayInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return newValue.copyWith(text: '');

    String formatted = '';
    for (int i = 0; i < digitsOnly.length && i < 8; i++) {
      if (i == 2 || i == 4) formatted += '/';
      formatted += digitsOnly[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

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

class TrainerProfileEditScreen extends StatefulWidget {
  const TrainerProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<TrainerProfileEditScreen> createState() =>
      _TrainerProfileEditScreenState();
}

class _TrainerProfileEditScreenState extends State<TrainerProfileEditScreen> {
  static const double _photoSize = 120.0;


  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _bioController = TextEditingController();
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();
  final _tiktokController = TextEditingController();
  final _twitterController = TextEditingController();
  final _youtubeController = TextEditingController();

  ImageProvider? _imageProvider;
  int? _selectedGender;
  String? _selectedColor;
  List<String> _selectedProfessions = [];
  List<String> _availableProfessions = [];
  bool _isSaving = false;
  bool _isLoading = true;
  bool _emailVerified = false;
  bool _isEmployeeActive = true;
  bool _isSendingVerification = false;
  bool _verificationCooldown = false;
  static const int _cooldownSeconds = 60;
  int _cooldownRemaining = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
      _loadProfessions();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    _bioController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    _tiktokController.dispose();
    _twitterController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  String? _getRandevuApiUrl() {
    var config = context.read<ExternalApplicationsConfigCubit>().state;
    return config?.onlineReservation;
  }

  bool _guardActive() {
    if (_isEmployeeActive) return true;
    warningDialog(
      context,
      message: AppLabels.current.accountPassiveProfileWarning,
      path: BlocTheme.theme.attentionSvgPath,
      buttonColor: BlocTheme.theme.default500Color,
      buttonTextColor: BlocTheme.theme.defaultBlackColor,
    );
    return false;
  }

  Future<void> _loadProfessions() async {
    final randevuUrl = _getRandevuApiUrl();
    if (randevuUrl == null || randevuUrl.isEmpty) return;

    try {
      final professions = await TrainerProfileService.fetchProfessions(
        randevuApiUrl: randevuUrl,
      );
      if (mounted) {
        setState(() => _availableProfessions = professions);
      }
    } catch (_) {}
  }

  Future<void> _loadProfile() async {
    final randevuUrl = _getRandevuApiUrl();
    if (randevuUrl == null || randevuUrl.isEmpty) {
      _loadFromUserConfig();
      return;
    }

    try {
      final response = await TrainerProfileService.fetchProfile(
        randevuApiUrl: randevuUrl,
      );

      if (response.isSuccess && response.outputMap != null) {
        _populateFields(response.outputMap!);
      } else {
        _loadFromUserConfig();
      }
    } catch (_) {
      _loadFromUserConfig();
    }

    if (mounted) setState(() => _isLoading = false);
    if (!_emailVerified) {
      _checkEmailVerificationFromIam();
    }
  }

  Future<void> _checkEmailVerificationFromIam() async {
    final cachedVerified = await EmailVerificationCacheUtils.isEmailVerified();
    if (cachedVerified) {
      if (mounted) setState(() => _emailVerified = true);
      return;
    }

    final randevuUrl = _getRandevuApiUrl();
    if (randevuUrl == null || randevuUrl.isEmpty) return;
    if (_emailController.text.trim().isEmpty) return;

    try {
      final verified = await TrainerProfileService.checkEmailVerified(
        randevuApiUrl: randevuUrl,
      );
      if (verified) {
        await EmailVerificationCacheUtils.setEmailVerified();
      }
      if (mounted) {
        setState(() => _emailVerified = verified);
      }
    } catch (_) {}
  }

  void _loadFromUserConfig() {
    final userConfig = context.read<UserConfigCubit>().state;
    if (userConfig == null) return;

    _nameController.text = _decodeName(userConfig.name.toString());
    _phoneController.text = userConfig.phone.toString();
    _emailController.text = userConfig.email.toString();
    _birthdayController.text = _formatBirthdayForDisplay(userConfig.birthday.toString());
    _selectedGender = userConfig.gender;

    if (userConfig.imageUrl != null &&
        userConfig.imageUrl != '' &&
        userConfig.imageUrl != 'null') {
      _imageProvider = Image.network(userConfig.imageUrl.toString()).image;
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _populateFields(Map<String, dynamic> data) {
    _nameController.text = _decodeName(data['name'] ?? '');
    _phoneController.text = data['phone'] ?? '';
    _emailController.text = data['email'] ?? '';
    _birthdayController.text = _formatBirthdayForDisplay(data['birthday'] ?? '');
    _selectedGender = data['gender'] as int?;
    _bioController.text = data['explanation'] ?? '';
    _selectedColor = data['color']?.toString();
    _instagramController.text = data['instagram'] ?? '';
    _facebookController.text = data['facebook'] ?? '';
    _tiktokController.text = data['tiktok'] ?? '';
    _twitterController.text = data['twitter'] ?? '';
    _youtubeController.text = data['youtube'] ?? '';

    final professionRaw = data['profession']?.toString() ?? '';
    if (professionRaw.isNotEmpty) {
      _selectedProfessions = professionRaw
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    _emailVerified = data['email_verified'] == true;
    _isEmployeeActive = data['is_active'] == true;

    final imageUrl = data['image']?.toString() ?? '';
    if (imageUrl.isNotEmpty) {
      _imageProvider = Image.network(imageUrl).image;
    }
  }

  String _formatBirthdayForDisplay(String raw) {
    if (raw.isEmpty) return '';
    if (raw.contains('/')) return raw;
    try {
      final parsed = DateTime.parse(raw);
      return DateFormat('dd/MM/yyyy').format(parsed);
    } catch (_) {
      return raw;
    }
  }

  String _formatBirthdayForApi(String display) {
    if (display.isEmpty) return '';
    try {
      final parsed = DateFormat('dd/MM/yyyy').parseStrict(display);
      return DateFormat('yyyy-MM-dd').format(parsed);
    } catch (_) {
      return display;
    }
  }

  String _decodeName(String name) {
    try {
      return jsonDecode('"$name"');
    } catch (_) {
      return name;
    }
  }

  Future<void> _saveProfile() async {
    if (!mounted || _isSaving) return;
    if (!_guardActive()) return;

    final labels = AppLabels.current;
    final randevuUrl = _getRandevuApiUrl();

    if (randevuUrl == null || randevuUrl.isEmpty) {
      await warningDialog(context, message: labels.apiConnectionNotFound);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final body = <String, dynamic>{
        'name': _nameController.text,
        'gender': _selectedGender ?? 0,
        'birthday': _formatBirthdayForApi(_birthdayController.text),
        'profession': _selectedProfessions.join(','),
        'color': _selectedColor,
        'explanation': _bioController.text,
        'instagram': _instagramController.text,
        'facebook': _facebookController.text,
        'tiktok': _tiktokController.text,
        'twitter': _twitterController.text,
        'youtube': _youtubeController.text,
      };

      final response = await TrainerProfileService.updateProfile(
        randevuApiUrl: randevuUrl,
        data: body,
      );

      if (response.isSuccess && mounted) {
        await warningDialog(context, message: labels.profileUpdateSuccess);
      } else if (mounted) {
        await warningDialog(context, message: labels.profileUpdateFailed);
      }
    } catch (e) {
      if (mounted) {
        await warningDialog(
          context,
          message: '${AppLabels.current.profileUpdateFailed}: $e',
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _resendEmailVerification() async {
    final randevuUrl = _getRandevuApiUrl();
    if (randevuUrl == null || randevuUrl.isEmpty) return;

    setState(() => _isSendingVerification = true);

    try {
      final response = await TrainerProfileService.resendEmailVerification(
        randevuApiUrl: randevuUrl,
      );

      if (mounted) {
        final labels = AppLabels.current;
        if (response.isSuccess) {
          _startCooldown();
          await warningDialog(
            context,
            message: labels.emailVerificationSent,
            path: BlocTheme.theme.attentionSvgPath,
            buttonColor: BlocTheme.theme.default500Color,
            buttonTextColor: BlocTheme.theme.defaultBlackColor,
          );
        } else {
          await warningDialog(
            context,
            message: response.message ?? labels.errorOccurred,
            path: BlocTheme.theme.errorSvgPath,
            buttonColor: BlocTheme.theme.default500Color,
            buttonTextColor: BlocTheme.theme.defaultBlackColor,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        await warningDialog(
          context,
          message: '${AppLabels.current.errorOccurred}: $e',
          path: BlocTheme.theme.errorSvgPath,
          buttonColor: BlocTheme.theme.default500Color,
          buttonTextColor: BlocTheme.theme.defaultBlackColor,
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingVerification = false);
    }
  }

  void _startCooldown() {
    setState(() {
      _verificationCooldown = true;
      _cooldownRemaining = _cooldownSeconds;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _cooldownRemaining--);
      if (_cooldownRemaining <= 0) {
        setState(() => _verificationCooldown = false);
        return false;
      }
      return true;
    });
  }

  Future<void> _handlePhotoUpdate() async {
    if (!_guardActive()) return;
    final randevuUrl = _getRandevuApiUrl();

    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ProfilePhotoUpdateDialogWidget(
        currentImage: _imageProvider,
        onUpload: randevuUrl != null && randevuUrl.isNotEmpty
            ? (imageFile) async {
                final response = await TrainerProfileService.uploadImage(
                  randevuApiUrl: randevuUrl,
                  imageFile: imageFile,
                );
                if (response.isSuccess && response.outputMap != null) {
                  final data = response.outputMap!;
                  return {
                    'image_url': (data['image'] ?? '').toString(),
                  };
                }
                return null;
              }
            : null,
        onDelete: randevuUrl != null && randevuUrl.isNotEmpty
            ? () async {
                final response = await TrainerProfileService.deleteImage(
                  randevuApiUrl: randevuUrl,
                );
                if (response.isSuccess) {
                  return {'deleted': 'true'};
                }
                return null;
              }
            : null,
      ),
    );

    if (result == null || !mounted) return;

    final isDeleted = result['deleted'] == 'true' || result['deleted'] == true;
    if (isDeleted) {
      setState(() => _imageProvider = null);
    } else {
      final imageUrl = result['image_url']?.toString() ?? '';
      if (imageUrl.isNotEmpty) {
        setState(() => _imageProvider = Image.network(imageUrl).image);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

    return Scaffold(
      appBar: TopAppBarWidget(title: labels.myProfile),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.default500Color,
              ),
            )
          : _buildForm(theme, labels),
      bottomNavigationBar: BottomNavigationBarWidget(
        tab: NavTab.profile,
      ),
    );
  }

  Widget _buildForm(dynamic theme, AppLabels labels) {
    return Container(
      margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20),
      decoration: BoxDecoration(
        color: theme.defaultWhiteColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            blurStyle: BlurStyle.outer,
            color: theme.defaultBlackColor,
            offset: Offset.zero,
            spreadRadius: 1,
          )
        ],
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(10.0),
      child: ListView(
        children: [
          _buildProfilePhotoRow(theme),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _nameController,
            label: labels.fullName,
            inputFormatters: [UpperCaseTextFormatter()],
            maxLength: 100,
          ),
          _buildPhoneField(theme, labels),
          _buildEmailField(theme, labels),
          _buildEmailVerificationStatus(theme, labels),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildGenderDropdown(theme, labels, padding: false)),
                const SizedBox(width: 10),
                Expanded(child: _buildBirthdayField(theme, labels, padding: false)),
              ],
            ),
          ),
          _buildProfessionMultiSelect(theme, labels),
          _buildColorSelector(theme, labels),
          _buildTextField(
            controller: _bioController,
            label: labels.biography,
            hintText: labels.biographyHint,
            maxLines: 4,
            maxLength: 1000,
          ),
          _buildSocialMediaSection(theme, labels),
          _buildChangePasswordButton(theme, labels),
          _buildSaveButton(theme, labels),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfilePhotoRow(dynamic theme) {
    const languageInsetFromRight = 10.0;

    return SizedBox(
      height: _photoSize,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: _photoSize,
            height: _photoSize,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                _imageProvider != null
                    ? GestureDetector(
                        onTap: () async => await _handlePhotoUpdate(),
                        child: ClipOval(
                          child: Image(
                            image: _imageProvider!,
                            width: _photoSize,
                            height: _photoSize,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : SvgPicture.asset(
                        theme.userSvgPath,
                        fit: BoxFit.contain,
                        width: _photoSize,
                        height: _photoSize,
                      ),
                Positioned(
                  top: 80,
                  right: -5,
                  child: GestureDetector(
                    onTap: () async => await _handlePhotoUpdate(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: theme.default100Color,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: theme.default900Color, width: 1),
                      ),
                      child: Icon(
                        Icons.edit,
                        color: theme.default700Color,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: languageInsetFromRight,
            child: ProfileLanguageSelectorWidget(
              onLocaleChanged: () => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
  }) {
    final theme = BlocTheme.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: TextFormField(
        controller: controller,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        cursorColor: theme.defaultBlackColor,
        style: theme.inputTextStyle(),
        decoration: theme.inputDecoration(
          labelText: label,
          hintText: hintText,
        ),
      ),
    );
  }

  Widget _buildEmailVerificationStatus(dynamic theme, AppLabels labels) {
    final email = _emailController.text.trim();
    if (email.isEmpty) return const SizedBox.shrink();

    if (_emailVerified) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        child: Row(
          children: [
            Icon(Icons.verified, color: theme.panelSuccessColor, size: 16),
            const SizedBox(width: 6),
            Text(
              labels.emailVerified,
              style: theme.textCaption(color: theme.panelSuccessColor),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: theme.panelWarningDarkColor, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              labels.emailNotVerified,
              style: theme.textCaption(color: theme.panelWarningDarkColor),
            ),
          ),
          const SizedBox(width: 8),
          if (_isSendingVerification)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.default500Color,
              ),
            )
          else if (_verificationCooldown)
            Text(
              labels.verificationSent,
              style: theme.textCaption(color: theme.defaultGray500Color),
            )
          else
            GestureDetector(
              onTap: _resendEmailVerification,
              child: Text(
                labels.sendVerification,
                style: theme.textCaptionSemiBold(
                  color: theme.default500Color,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhoneField(dynamic theme, AppLabels labels) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: TextFormField(
        controller: _phoneController,
        readOnly: true,
        style: theme.inputTextStyle(color: theme.defaultGray700Color),
        decoration: theme.inputDecoration(
          labelText: labels.phoneNumber,
          readOnly: true,
          prefixIcon: Icon(Icons.lock_outline,
              color: theme.defaultGray700Color, size: 20),
          suffixIcon: GestureDetector(
            onTap: _handleChangePhone,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                Icons.edit,
                color: theme.default500Color,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleChangePhone() async {
    if (!_guardActive()) return;
    final randevuUrl = _getRandevuApiUrl();
    if (randevuUrl == null || randevuUrl.isEmpty) return;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PhoneChangeDialogWidget(
        currentPhone: _phoneController.text.trim(),
        onCheckPhone: (phone) async {
          final response = await TrainerProfileService.checkPhone(
            randevuApiUrl: randevuUrl,
            phone: phone,
          );
          if (response.isSuccess && response.outputMap != null) {
            return response.outputMap!['exists'] == true;
          }
          return null;
        },
        onChangePhone: (phone) async {
          final response = await TrainerProfileService.changePhone(
            randevuApiUrl: randevuUrl,
            phone: phone,
          );
          return response.isSuccess;
        },
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      setState(() {
        _phoneController.text = result;
      });
    }
  }

  Widget _buildChangePasswordButton(dynamic theme, AppLabels labels) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: OutlinedButton.icon(
        onPressed: _handleChangePassword,
        icon: Icon(Icons.lock_outline, color: theme.default700Color, size: 20),
        label: Text(
          labels.changePassword,
          style: theme.textBody(color: theme.default700Color),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.default700Color,
          side: BorderSide(color: theme.default500Color),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Future<void> _handleChangePassword() async {
    if (!_guardActive()) return;
    final randevuUrl = _getRandevuApiUrl();
    if (randevuUrl == null || randevuUrl.isEmpty) return;

    final labels = AppLabels.current;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PasswordChangeDialogWidget(
        onChangePassword: (currentPassword, newPassword) async {
          try {
            final response = await TrainerProfileService.changePassword(
              randevuApiUrl: randevuUrl,
              currentPassword: currentPassword,
              newPassword: newPassword,
            );
            if (response.statusCode >= 200 &&
                response.statusCode < 300 &&
                response.body is Map) {
              final body = response.body as Map;
              final messages = body['messages'];
              if (messages == 'UPDATED') {
                return {'success': true};
              }
              final status = body['status'];
              if (status == 401 || status == '401') {
                return {
                  'success': false,
                  'message': labels.currentPasswordWrong,
                };
              }
              return {
                'success': false,
                'message': body['extras']?.toString() ??
                    labels.passwordChangeFailed,
              };
            }
            return {'success': false, 'message': labels.passwordChangeFailed};
          } catch (_) {
            return {'success': false, 'message': labels.passwordChangeFailed};
          }
        },
      ),
    );

    if (result == true && mounted) {
      warningDialog(
        context,
        message: labels.passwordChangeSuccess,
      );
    }
  }

  Widget _buildEmailField(dynamic theme, AppLabels labels) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: TextFormField(
        controller: _emailController,
        readOnly: true,
        style: theme.inputTextStyle(color: theme.defaultGray700Color),
        decoration: theme.inputDecoration(
          labelText: labels.email,
          readOnly: true,
          prefixIcon: Icon(Icons.lock_outline,
              color: theme.defaultGray700Color, size: 20),
          suffixIcon: !_emailVerified
              ? GestureDetector(
                  onTap: _handleChangeEmail,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.edit,
                      color: theme.default500Color,
                      size: 20,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Future<void> _handleChangeEmail() async {
    if (!_guardActive()) return;
    final randevuUrl = _getRandevuApiUrl();
    if (randevuUrl == null || randevuUrl.isEmpty) return;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EmailChangeDialogWidget(
        currentEmail: _emailController.text.trim(),
        onCheckEmail: (email) async {
          final response = await TrainerProfileService.checkEmail(
            randevuApiUrl: randevuUrl,
            email: email,
          );
          if (response.isSuccess && response.outputMap != null) {
            return response.outputMap!['exists'] == true;
          }
          return null;
        },
        onChangeEmail: (email) async {
          final response = await TrainerProfileService.changeEmail(
            randevuApiUrl: randevuUrl,
            email: email,
          );
          return response.isSuccess;
        },
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      setState(() {
        _emailController.text = result;
        _emailVerified = false;
      });
      await EmailVerificationCacheUtils.clearEmailVerified();
    }
  }

  Widget _buildReadOnlyField({
    required TextEditingController controller,
    required String label,
  }) {
    final theme = BlocTheme.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        style: theme.inputTextStyle(color: theme.defaultGray700Color),
        decoration: theme.inputDecoration(
          labelText: label,
          readOnly: true,
          prefixIcon: Icon(Icons.lock_outline,
              color: theme.defaultGray700Color, size: 20),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown(dynamic theme, AppLabels labels,
      {bool padding = true}) {
    final child = DropdownButtonFormField<int>(
      value: _selectedGender,
      decoration: theme.inputDecoration(labelText: labels.gender),
      dropdownColor: theme.defaultWhiteColor,
      style: theme.inputTextStyle(),
      icon: Icon(Icons.arrow_drop_down, color: theme.defaultBlackColor),
      items: [
        DropdownMenuItem(
          value: 0,
          child: Text(labels.male, style: theme.inputTextStyle()),
        ),
        DropdownMenuItem(
          value: 1,
          child: Text(labels.female, style: theme.inputTextStyle()),
        ),
      ],
      onChanged: (value) => setState(() => _selectedGender = value),
    );
    if (!padding) return child;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: child,
    );
  }

  Widget _buildBirthdayField(dynamic theme, AppLabels labels,
      {bool padding = true}) {
    final child = TextFormField(
      controller: _birthdayController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
        LengthLimitingTextInputFormatter(10),
        _BirthdayInputFormatter(),
      ],
      maxLength: 10,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      cursorColor: theme.defaultBlackColor,
      style: theme.inputTextStyle(),
      decoration: theme.inputDecoration(
        labelText: labels.birthDate,
        hintText: labels.birthDateFormat,
        counterText: '',
        prefixIcon: InkWell(
          onTap: () async => await _showDatePicker(theme),
          child: Icon(Icons.cake_outlined, color: theme.defaultBlackColor),
        ),
      ),
    );
    if (!padding) return child;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: child,
    );
  }

  Future<void> _showDatePicker(dynamic theme) async {
    DateTime? initialDate;
    if (_birthdayController.text.isNotEmpty) {
      try {
        final parts = _birthdayController.text.split('/');
        if (parts.length == 3) {
          initialDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (_) {}
    }
    initialDate ??= DateTime.now().subtract(const Duration(days: 365 * 25));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: theme.default600Color,
              ),
            ),
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: theme.default600Color,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthdayController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Widget _buildProfessionMultiSelect(dynamic theme, AppLabels labels) {
    final professionLabels = labels.professionLabels;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (!_guardActive()) return;
              _showProfessionBottomSheet(theme, labels);
            },
            child: InputDecorator(
              decoration: theme.inputDecoration(
                labelText: labels.expertise,
                suffixIcon: Icon(
                  Icons.arrow_drop_down_circle_outlined,
                  color: theme.default700Color,
                  size: 22,
                ),
              ),
              child: _selectedProfessions.isEmpty
                  ? Row(
                      children: [
                        Icon(Icons.work_outline,
                            size: 18, color: theme.defaultGray500Color),
                        const SizedBox(width: 8),
                        Text(
                          labels.selectExpertise,
                          style: theme.inputTextStyle(
                              color: theme.defaultGray700Color),
                        ),
                      ],
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: ProfessionKeysSortUtils.sortedKeys(
                        _selectedProfessions,
                        professionLabels,
                      ).map((key) {
                        final label = ProfessionKeysSortUtils.displayLabel(
                          key,
                          professionLabels,
                        );
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.default500Color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.default500Color.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                label,
                                style: theme.textCaptionSemiBold(
                                    color: theme.default900Color),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedProfessions.remove(key);
                                  });
                                },
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: theme.default700Color,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProfessionBottomSheet(dynamic theme, AppLabels labels) {
    final professionLabels = labels.professionLabels;
    final rawKeys = _availableProfessions.isNotEmpty
        ? List<String>.from(_availableProfessions)
        : professionLabels.keys.toList();
    final items = ProfessionKeysSortUtils.sortedKeys(
      rawKeys,
      professionLabels,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              decoration: BoxDecoration(
                color: theme.defaultWhiteColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.defaultGray300Color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Row(
                        children: [
                          Icon(Icons.work_outline,
                              color: theme.default600Color, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            labels.selectExpertise,
                            style: theme.textLabelBold(
                                color: theme.defaultBlackColor),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.default500Color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_selectedProfessions.length}',
                              style: theme.textCaptionSemiBold(
                                  color: theme.default700Color),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                        height: 1, color: theme.defaultGray200Color),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          indent: 56,
                          color: theme.defaultGray100Color,
                        ),
                        itemBuilder: (context, index) {
                          final key = items[index];
                          final label = ProfessionKeysSortUtils.displayLabel(
                            key,
                            professionLabels,
                          );
                          final isSelected =
                              _selectedProfessions.contains(key);

                          return ListTile(
                            leading: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.default500Color
                                    : theme.defaultGray100Color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isSelected
                                    ? Icons.check
                                    : Icons.add,
                                size: 18,
                                color: isSelected
                                    ? theme.defaultWhiteColor
                                    : theme.defaultGray500Color,
                              ),
                            ),
                            title: Text(
                              label,
                              style: theme.textBody(
                                color: isSelected
                                    ? theme.default700Color
                                    : theme.defaultBlackColor,
                              ).copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            onTap: () {
                              setStateSheet(() {
                                setState(() {
                                  if (isSelected) {
                                    _selectedProfessions.remove(key);
                                  } else {
                                    _selectedProfessions.add(key);
                                  }
                                });
                              });
                            },
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: theme.defaultGray200Color),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.pop(bottomSheetContext),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.default500Color,
                            foregroundColor: theme.defaultWhiteColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(labels.confirm,
                              style: theme.panelButtonTextStyle),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildColorSelector(dynamic theme, AppLabels labels) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              if (!_guardActive()) return;
              final result = await showDialog<String>(
                context: context,
                builder: (_) => ColorPickerDialogWidget(
                  currentColor: _selectedColor,
                ),
              );
              if (result != null) {
                setState(() {
                  _selectedColor = result.isEmpty ? null : result;
                });
              }
            },
            child: InputDecorator(
              decoration: theme.inputDecoration(
                labelText: labels.colorLabel,
              ),
              child: _selectedColor != null && _selectedColor!.isNotEmpty
                  ? Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _colorFromHex(_selectedColor!),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: theme.defaultGray300Color, width: 1),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _selectedColor!,
                          style: theme.inputTextStyle(),
                        ),
                      ],
                    )
                  : Text(
                      labels.selectColor,
                      style: theme.inputTextStyle(
                          color: theme.defaultGray700Color),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFromHex(String hex) {
    final cleaned = hex.replaceAll('#', '');
    if (cleaned.length == 6) {
      return Color(int.parse('FF$cleaned', radix: 16));
    }
    return BlocTheme.theme.defaultGrayColor;
  }

  Widget _buildSocialMediaSection(dynamic theme, AppLabels labels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _buildSocialField(
          controller: _instagramController,
          label: 'Instagram',
          icon: Icons.camera_alt_outlined,
          hintText: 'https://instagram.com/username',
        ),
        _buildSocialField(
          controller: _facebookController,
          label: 'Facebook',
          icon: Icons.facebook_outlined,
          hintText: 'https://facebook.com/username',
        ),
        _buildSocialField(
          controller: _tiktokController,
          label: 'TikTok',
          icon: Icons.music_note_outlined,
          hintText: 'https://tiktok.com/@username',
        ),
        _buildSocialField(
          controller: _twitterController,
          label: 'X (Twitter)',
          icon: Icons.alternate_email,
          hintText: 'https://x.com/username',
        ),
        _buildSocialField(
          controller: _youtubeController,
          label: 'YouTube',
          icon: Icons.play_circle_outline,
          hintText: 'https://youtube.com/@channel',
        ),
      ],
    );
  }

  Widget _buildSocialField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
  }) {
    final theme = BlocTheme.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: TextFormField(
        controller: controller,
        style: theme.inputTextStyle(),
        keyboardType: TextInputType.url,
        decoration: theme.inputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon, color: theme.default500Color, size: 22),
        ),
      ),
    );
  }

  Widget _buildSaveButton(dynamic theme, AppLabels labels) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _isSaving ? null : () async => await _saveProfile(),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.default500Color,
                foregroundColor: theme.defaultWhiteColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                disabledBackgroundColor: theme.default500Color.withOpacity(0.6),
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(theme.defaultWhiteColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          labels.saving,
                          style: theme.textBody(
                              color: theme.defaultWhiteColor),
                        ),
                      ],
                    )
                  : Text(
                      labels.save,
                      style: theme.textBody(
                          color: theme.defaultBlackColor),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                      await logoutAppDialog(
                        context,
                        message: labels.logoutConfirm,
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.defaultRed700Color,
                foregroundColor: theme.defaultWhiteColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                labels.logout,
                style: theme.textBody(
                    color: theme.defaultWhiteColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
