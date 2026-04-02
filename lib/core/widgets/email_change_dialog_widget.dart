import 'dart:async';

import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:flutter/material.dart';

enum _EmailCheckStatus { checking, available, taken, same, invalid, error }

class EmailChangeDialogWidget extends StatefulWidget {
  final String currentEmail;
  final Future<bool?> Function(String email) onCheckEmail;
  final Future<bool> Function(String email) onChangeEmail;

  const EmailChangeDialogWidget({
    Key? key,
    required this.currentEmail,
    required this.onCheckEmail,
    required this.onChangeEmail,
  }) : super(key: key);

  @override
  State<EmailChangeDialogWidget> createState() =>
      _EmailChangeDialogWidgetState();
}

class _EmailChangeDialogWidgetState extends State<EmailChangeDialogWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  _EmailCheckStatus? _status;
  String _message = '';
  bool _isSaving = false;

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onEmailChanged);
    Future.microtask(() => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    _debounce?.cancel();
    final email = _controller.text.trim();

    if (email.isEmpty) {
      setState(() {
        _status = null;
        _message = '';
      });
      return;
    }

    if (!_emailRegex.hasMatch(email)) {
      setState(() {
        _status = _EmailCheckStatus.invalid;
        _message = AppLabels.current.invalidEmailFormat;
      });
      return;
    }

    if (email.toLowerCase() == widget.currentEmail.toLowerCase()) {
      setState(() {
        _status = _EmailCheckStatus.same;
        _message = AppLabels.current.emailSameAsCurrent;
      });
      return;
    }

    setState(() {
      _status = _EmailCheckStatus.checking;
      _message = AppLabels.current.emailChecking;
    });

    _debounce = Timer(const Duration(milliseconds: 600), () {
      _checkAvailability(email);
    });
  }

  Future<void> _checkAvailability(String email) async {
    try {
      final exists = await widget.onCheckEmail(email);
      if (!mounted) return;
      if (_controller.text.trim() != email) return;

      if (exists == null) {
        setState(() {
          _status = _EmailCheckStatus.error;
          _message = AppLabels.current.emailCheckError;
        });
      } else if (exists) {
        setState(() {
          _status = _EmailCheckStatus.taken;
          _message = AppLabels.current.emailTaken;
        });
      } else {
        setState(() {
          _status = _EmailCheckStatus.available;
          _message = AppLabels.current.emailAvailable;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _status = _EmailCheckStatus.error;
        _message = AppLabels.current.emailCheckError;
      });
    }
  }

  Future<void> _save() async {
    if (_status != _EmailCheckStatus.available || _isSaving) return;
    setState(() => _isSaving = true);

    try {
      final success = await widget.onChangeEmail(_controller.text.trim());
      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop(_controller.text.trim());
      } else {
        setState(() {
          _status = _EmailCheckStatus.error;
          _message = AppLabels.current.emailChangeFailed;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _status = _EmailCheckStatus.error;
        _message = AppLabels.current.emailChangeFailed;
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Color _statusColor(dynamic theme) {
    switch (_status) {
      case _EmailCheckStatus.available:
        return theme.default700Color;
      case _EmailCheckStatus.taken:
      case _EmailCheckStatus.error:
        return theme.panelDangerColor;
      case _EmailCheckStatus.same:
      case _EmailCheckStatus.invalid:
        return theme.panelWarningDarkColor;
      case _EmailCheckStatus.checking:
        return theme.defaultGray500Color;
      default:
        return theme.defaultGray500Color;
    }
  }

  IconData _statusIcon() {
    switch (_status) {
      case _EmailCheckStatus.available:
        return Icons.check_circle_outline;
      case _EmailCheckStatus.taken:
      case _EmailCheckStatus.error:
        return Icons.error_outline;
      case _EmailCheckStatus.same:
      case _EmailCheckStatus.invalid:
        return Icons.warning_amber_rounded;
      case _EmailCheckStatus.checking:
        return Icons.hourglass_empty;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;
    final canSave = _status == _EmailCheckStatus.available && !_isSaving;

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
                    Icons.email_outlined,
                    color: theme.default700Color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  labels.changeEmail,
                  style: theme.textLabelBold(color: theme.default700Color),
                ),
                if (widget.currentEmail.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.currentEmail,
                    style: theme.textCaption(color: theme.defaultGray500Color),
                  ),
                ],
                const SizedBox(height: 20),
                TextFormField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  style: theme.inputTextStyle(),
                  decoration: theme.inputDecoration(
                    labelText: labels.newEmail,
                    suffixIcon: _status == _EmailCheckStatus.checking
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.default500Color,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
                if (_status != null && _message.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(_statusIcon(), color: _statusColor(theme), size: 16),
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          labels.cancel,
                          style:
                              theme.textBody(color: theme.defaultWhiteColor),
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
                          disabledBackgroundColor: theme.defaultGray300Color,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
