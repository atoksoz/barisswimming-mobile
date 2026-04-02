import 'dart:async';

import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/widgets/country_picker_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/countries.dart';

enum _PhoneCheckStatus { checking, available, taken, same, invalid, error }

class PhoneChangeDialogWidget extends StatefulWidget {
  final String currentPhone;
  final Future<bool?> Function(String phone) onCheckPhone;
  final Future<bool> Function(String phone) onChangePhone;

  const PhoneChangeDialogWidget({
    Key? key,
    required this.currentPhone,
    required this.onCheckPhone,
    required this.onChangePhone,
  }) : super(key: key);

  @override
  State<PhoneChangeDialogWidget> createState() =>
      _PhoneChangeDialogWidgetState();
}

class _PhoneChangeDialogWidgetState extends State<PhoneChangeDialogWidget> {
  final _phoneController = TextEditingController();
  Timer? _debounce;
  Country _selectedCountry = countries.firstWhere(
    (c) => c.code == 'TR',
    orElse: () => countries.first,
  );
  String _completeNumber = '';

  _PhoneCheckStatus? _status;
  String _message = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  String _cleanPhone(String raw) => raw.replaceAll(RegExp(r'[\s\-()]+'), '');

  String get _buildCompleteNumber {
    final digits = _cleanPhone(_phoneController.text);
    if (digits.isEmpty) return '';
    return '+${_selectedCountry.dialCode}$digits';
  }

  void _onPhoneChanged() {
    _debounce?.cancel();

    _completeNumber = _buildCompleteNumber;
    final digits = _cleanPhone(_phoneController.text);
    final isValid = digits.length >= 7;

    if (!isValid) {
      setState(() {
        _status = null;
        _message = '';
      });
      return;
    }

    if (_completeNumber == _cleanPhone(widget.currentPhone)) {
      setState(() {
        _status = _PhoneCheckStatus.same;
        _message = AppLabels.current.phoneSameAsCurrent;
      });
      return;
    }

    setState(() {
      _status = _PhoneCheckStatus.checking;
      _message = AppLabels.current.phoneChecking;
    });

    _debounce = Timer(const Duration(milliseconds: 600), () {
      _checkAvailability(_completeNumber);
    });
  }

  Future<void> _checkAvailability(String phone) async {
    try {
      final exists = await widget.onCheckPhone(phone);
      if (!mounted) return;
      if (_completeNumber != phone) return;

      if (exists == null) {
        setState(() {
          _status = _PhoneCheckStatus.error;
          _message = AppLabels.current.phoneCheckError;
        });
      } else if (exists) {
        setState(() {
          _status = _PhoneCheckStatus.taken;
          _message = AppLabels.current.phoneTaken;
        });
      } else {
        setState(() {
          _status = _PhoneCheckStatus.available;
          _message = AppLabels.current.phoneAvailable;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _status = _PhoneCheckStatus.error;
        _message = AppLabels.current.phoneCheckError;
      });
    }
  }

  Future<void> _save() async {
    if (_status != _PhoneCheckStatus.available || _isSaving) return;
    setState(() => _isSaving = true);

    try {
      final success = await widget.onChangePhone(_completeNumber);
      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop(_completeNumber);
      } else {
        setState(() {
          _status = _PhoneCheckStatus.error;
          _message = AppLabels.current.phoneChangeFailed;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _status = _PhoneCheckStatus.error;
        _message = AppLabels.current.phoneChangeFailed;
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _openCountryPicker() async {
    await showDialog(
      context: context,
      builder: (_) => CountryPickerDialogWidget(
        countries: countries,
        selectedCountry: _selectedCountry,
        onCountrySelected: (country) {
          setState(() => _selectedCountry = country);
          _onPhoneChanged();
        },
      ),
    );
  }

  Color _statusColor(dynamic theme) {
    switch (_status) {
      case _PhoneCheckStatus.available:
        return theme.default700Color;
      case _PhoneCheckStatus.taken:
      case _PhoneCheckStatus.error:
        return theme.panelDangerColor;
      case _PhoneCheckStatus.same:
      case _PhoneCheckStatus.invalid:
        return theme.panelWarningDarkColor;
      case _PhoneCheckStatus.checking:
        return theme.defaultGray500Color;
      default:
        return theme.defaultGray500Color;
    }
  }

  IconData _statusIcon() {
    switch (_status) {
      case _PhoneCheckStatus.available:
        return Icons.check_circle_outline;
      case _PhoneCheckStatus.taken:
      case _PhoneCheckStatus.error:
        return Icons.error_outline;
      case _PhoneCheckStatus.same:
      case _PhoneCheckStatus.invalid:
        return Icons.warning_amber_rounded;
      case _PhoneCheckStatus.checking:
        return Icons.hourglass_empty;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildPhoneInput(dynamic theme, AppLabels labels) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _openCountryPicker,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: theme.defaultBlackColor, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedCountry.flag,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 6),
                Text(
                  '+${_selectedCountry.dialCode}',
                  style: theme.textBody(color: theme.defaultBlackColor),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down,
                    color: theme.defaultBlackColor, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: theme.inputTextStyle(),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              LengthLimitingTextInputFormatter(15),
            ],
            decoration: theme.inputDecoration(
              labelText: labels.newPhone,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;
    final canSave = _status == _PhoneCheckStatus.available && !_isSaving;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.defaultWhiteColor,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.default100Color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phone_outlined,
                    color: theme.default700Color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  labels.changePhone,
                  style: theme.textLabelBold(color: theme.default700Color),
                ),
                if (widget.currentPhone.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.currentPhone,
                    style: theme.textCaption(color: theme.defaultGray500Color),
                  ),
                ],
                const SizedBox(height: 20),
                _buildPhoneInput(theme, labels),
                if (_status != null && _message.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(_statusIcon(),
                          color: _statusColor(theme), size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _message,
                          style:
                              theme.textCaption(color: _statusColor(theme)),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.panelDangerColor,
                          foregroundColor: theme.defaultWhiteColor,
                          elevation: 0,
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          labels.cancel,
                          style: theme.textBody(
                              color: theme.defaultWhiteColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: canSave ? _save : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.default500Color,
                          foregroundColor: theme.defaultWhiteColor,
                          disabledBackgroundColor:
                              theme.defaultGray300Color,
                          elevation: 0,
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isSaving
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.defaultWhiteColor,
                                ),
                              )
                            : Text(
                                labels.save,
                                style: theme.textBody(
                                  color: theme.defaultBlackColor,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.default500Color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: theme.defaultBlackColor,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
