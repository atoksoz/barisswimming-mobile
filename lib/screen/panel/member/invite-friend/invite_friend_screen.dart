import 'dart:convert';

import 'package:e_sport_life/config/app-content/app_content_cubit.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/potential_customer_service.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/core/widgets/warning_dialog_widget.dart';
import 'package:e_sport_life/screen/panel/common/tabs/tabs_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  String _toTurkishUpperCase(String text) {
    return text
        .replaceAll('ı', 'I')
        .replaceAll('i', 'İ')
        .replaceAll('ğ', 'Ğ')
        .replaceAll('ü', 'Ü')
        .replaceAll('ş', 'Ş')
        .replaceAll('ö', 'Ö')
        .replaceAll('ç', 'Ç')
        .toUpperCase();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: _toTurkishUpperCase(newValue.text),
      selection: newValue.selection,
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.length < 4 || !text.startsWith('+90')) {
      if (oldValue.text.startsWith('+90 ')) {
        return TextEditingValue(
          text: '+90 ',
          selection: TextSelection.collapsed(offset: 4),
        );
      }
    }

    String digitsOnly = '';
    if (text.length > 4) {
      String afterPrefix = text.substring(4);
      digitsOnly = afterPrefix.replaceAll(RegExp(r'[^0-9]'), '');
    }

    if (digitsOnly.isNotEmpty && digitsOnly[0] == '0') {
      digitsOnly = digitsOnly.substring(1);
    }

    if (digitsOnly.length > 10) {
      digitsOnly = digitsOnly.substring(0, 10);
    }

    String formatted = '+90 ';

    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 0) {
        formatted += '(';
        formatted += digitsOnly[i];
      } else if (i == 3) {
        formatted += ') ';
        formatted += digitsOnly[i];
      } else if (i == 6) {
        formatted += ' ';
        formatted += digitsOnly[i];
      } else if (i == 8) {
        formatted += ' ';
        formatted += digitsOnly[i];
      } else {
        formatted += digitsOnly[i];
      }
    }

    int cursorPosition = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

class InviteFriendScreen extends StatefulWidget {
  const InviteFriendScreen({Key? key}) : super(key: key);

  @override
  State<InviteFriendScreen> createState() => _InviteFriendScreenState();
}

class _InviteFriendScreenState extends State<InviteFriendScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  int? _selectedGender;
  String _kvkkContent = '';

  @override
  void initState() {
    super.initState();
    _loadKvkkContent();
    _phoneController.text = '+90 ';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
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

  Future<void> _showKvkkDialog() async {
    final theme = BlocTheme.theme;
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(AppLabels.current.kvkkTitle),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Text(
                _kvkkContent,
                style: theme.textSmallNormal(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              style: TextButton.styleFrom(
                foregroundColor: theme.default500Color,
              ),
              child: Text(AppLabels.current.close),
            ),
          ],
        );
      },
    );
  }

  bool _isFormValid() {
    if (_nameController.text.trim().isEmpty) return false;
    if (_selectedGender == null) return false;

    String phoneText = _phoneController.text;
    if (phoneText.length < 4 || !phoneText.startsWith('+90')) return false;

    String digitsOnly =
        phoneText.substring(4).replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length != 10) return false;
    if (digitsOnly.isNotEmpty && digitsOnly[0] != '5') return false;

    return true;
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _selectedGender = null;
      _phoneController.text = '+90 ';
    });
  }

  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Tabs(index: 0)),
      (route) => false,
    );
  }

  String _formatPhoneForApi(String phoneText) {
    if (!phoneText.startsWith('+90')) return phoneText;
    String digitsOnly =
        phoneText.substring(4).replaceAll(RegExp(r'[^0-9]'), '');
    return '+90$digitsOnly';
  }

  String _formatPhoneForDisplay(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    if (cleanPhone.startsWith('+90')) {
      String digits = cleanPhone.substring(3);

      if (digits.startsWith('0')) {
        digits = digits.substring(1);
      }

      if (digits.length > 10) {
        digits = digits.substring(0, 10);
      }

      String formatted = '+90 ';

      for (int i = 0; i < digits.length; i++) {
        if (i == 0) {
          formatted += '(';
          formatted += digits[i];
        } else if (i == 3) {
          formatted += ') ';
          formatted += digits[i];
        } else if (i == 6) {
          formatted += ' ';
          formatted += digits[i];
        } else if (i == 8) {
          formatted += ' ';
          formatted += digits[i];
        } else {
          formatted += digits[i];
        }
      }

      return formatted;
    }

    return phone;
  }

  Future<void> _pickContactFromPhoneBook() async {
    try {
      if (!await FlutterContacts.requestPermission(readonly: true)) {
        await warningDialog(
          context,
          message: AppLabels.current.contactPermissionRequired,
          path: BlocTheme.theme.attentionSvgPath,
        );
        return;
      }

      final contact = await FlutterContacts.openExternalPick();

      if (contact != null) {
        final fullContact = await FlutterContacts.getContact(contact.id);

        if (fullContact != null) {
          String name = '';
          String phone = '';

          if (fullContact.displayName.isNotEmpty) {
            name = fullContact.displayName;
          } else if (fullContact.name.first.isNotEmpty ||
              fullContact.name.last.isNotEmpty) {
            name = '${fullContact.name.first} ${fullContact.name.last}'.trim();
          }

          if (fullContact.phones.isNotEmpty) {
            phone = fullContact.phones.first.number;
            phone = phone.replaceAll(RegExp(r'[^0-9+]'), '');

            if (phone.startsWith('0')) {
              phone = '+90${phone.substring(1)}';
            } else if (!phone.startsWith('+') && phone.length == 10) {
              phone = '+90$phone';
            } else if (!phone.startsWith('+90') && phone.startsWith('+')) {
              // Accept other country codes as-is
            } else if (!phone.startsWith('+')) {
              phone = '+90$phone';
            }
          }

          setState(() {
            if (name.isNotEmpty) {
              _nameController.text = name.toUpperCase();
            }
            if (phone.isNotEmpty) {
              _phoneController.text = _formatPhoneForDisplay(phone);
            }
          });
        }
      }
    } catch (e) {
      await warningDialog(
        context,
        message: AppLabels.current.contactPickError,
        path: BlocTheme.theme.attentionSvgPath,
      );
    }
  }

  Future<void> _handleSend() async {
    if (!_isFormValid()) {
      await warningDialog(
        context,
        message: AppLabels.current.fillRequiredFieldsAndPhone,
        path: BlocTheme.theme.attentionSvgPath,
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      String phoneForApi = _formatPhoneForApi(_phoneController.text);

      final success = await PotentialCustomerService.createWithReference(
        context: context,
        name: _nameController.text.trim(),
        phone: phoneForApi,
        gender: _selectedGender!,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (success) {
        await warningDialog(
          context,
          message: AppLabels.current.inviteSentSuccess,
          path: BlocTheme.theme.attentionSvgPath,
          primaryButtonText: AppLabels.current.retry,
          secondaryButtonText: AppLabels.current.close,
          secondaryButtonTextColor: BlocTheme.theme.defaultWhiteColor,
          onPrimaryPressed: _clearForm,
          onSecondaryPressed: _navigateToHome,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }

      await warningDialog(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        path: BlocTheme.theme.attentionSvgPath,
        buttonColor: BlocTheme.theme.defaultRed700Color,
        buttonTextColor: BlocTheme.theme.defaultWhiteColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

    return Scaffold(
      backgroundColor: theme.defaultWhiteColor,
      appBar: TopAppBarWidget(title: labels.inviteFriendTitle),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                theme.inviteFriendSvgPath,
                width: 90,
                height: 90,
                colorFilter: ColorFilter.mode(
                  theme.default900Color,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                labels.enterFriendInfo,
                textAlign: TextAlign.center,
                style: theme.panelBodyStyle.copyWith(
                  color: theme.default900Color,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                autofocus: false,
                onChanged: (value) {
                  String toTurkishUpperCase(String text) {
                    return text
                        .replaceAll('ı', 'I')
                        .replaceAll('i', 'İ')
                        .replaceAll('ğ', 'Ğ')
                        .replaceAll('ü', 'Ü')
                        .replaceAll('ş', 'Ş')
                        .replaceAll('ö', 'Ö')
                        .replaceAll('ç', 'Ç')
                        .toUpperCase();
                  }

                  final upperValue = toTurkishUpperCase(value);
                  if (value != upperValue) {
                    final cursorPosition =
                        _nameController.selection.baseOffset;
                    _nameController.value = TextEditingValue(
                      text: upperValue,
                      selection: TextSelection.collapsed(
                        offset: cursorPosition <= upperValue.length
                            ? cursorPosition
                            : upperValue.length,
                      ),
                    );
                  }
                  setState(() {});
                },
                inputFormatters: [
                  UpperCaseTextFormatter(),
                ],
                decoration: theme.inputDecoration(
                  labelText: '${labels.fullName} *',
                ),
                style: theme.inputTextStyle(),
                maxLength: 100,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                cursorColor: theme.defaultBlackColor,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: _selectedGender,
                decoration: theme.inputDecoration(
                  labelText: '${labels.gender} *',
                ),
                dropdownColor: theme.defaultWhiteColor,
                style: theme.inputTextStyle(),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: theme.defaultBlackColor,
                ),
                iconEnabledColor: theme.defaultBlackColor,
                items: [
                  DropdownMenuItem<int>(
                    value: 0,
                    child: Text(
                      labels.male,
                      style: theme.inputTextStyle(),
                    ),
                  ),
                  DropdownMenuItem<int>(
                    value: 1,
                    child: Text(
                      labels.female,
                      style: theme.inputTextStyle(),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextFormField(
                    controller: _phoneController,
                    autofocus: false,
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      setState(() {});
                    },
                    inputFormatters: [
                      PhoneNumberFormatter(),
                    ],
                    decoration: theme.inputDecoration(
                      labelText: '${labels.phoneNumber} *',
                    ),
                    style: theme.inputTextStyle(),
                    maxLength: 100,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    cursorColor: theme.defaultBlackColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, right: 4),
                    child: GestureDetector(
                      onTap: _pickContactFromPhoneBook,
                      child: Text(
                        labels.selectFromContacts,
                        style: theme
                            .textCaptionSemiBold(color: theme.default500Color)
                            .copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: theme.default500Color,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: theme
                        .textMini(color: theme.defaultBlackColor)
                        .copyWith(fontSize: 11, height: 1.4),
                    children: [
                      TextSpan(
                        text: labels.inviteKvkkConsentPrefix,
                      ),
                      TextSpan(
                        text: labels.kvkkTitle,
                        style: theme
                            .textMini(color: theme.defaultBlackColor)
                            .copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = _showKvkkDialog,
                      ),
                      TextSpan(
                        text: labels.inviteKvkkConsentSuffix,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isFormValid() ? _handleSend : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFormValid()
                        ? theme.default500Color
                        : theme.defaultGray300Color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    labels.send,
                    style: theme.textLabelBold(
                      color: _isFormValid()
                          ? theme.defaultBlackColor
                          : theme.defaultGray500Color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(tab: NavTab.home),
    );
  }
}
