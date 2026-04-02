import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:flutter/material.dart';

class PasswordChangeDialogWidget extends StatefulWidget {
  final Future<Map<String, dynamic>> Function(
      String currentPassword, String newPassword) onChangePassword;

  const PasswordChangeDialogWidget({
    Key? key,
    required this.onChangePassword,
  }) : super(key: key);

  @override
  State<PasswordChangeDialogWidget> createState() =>
      _PasswordChangeDialogWidgetState();
}

class _PasswordChangeDialogWidgetState
    extends State<PasswordChangeDialogWidget> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;

  String? _errorMessage;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validate(AppLabels labels) {
    final current = _currentController.text.trim();
    final newPass = _newController.text.trim();
    final confirm = _confirmController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) return null;

    if (newPass.length < 6) return labels.passwordMinLength;
    if (newPass != confirm) return labels.passwordMismatch;
    if (newPass == current) return labels.passwordSameAsOld;

    return null;
  }

  bool get _canSave {
    final current = _currentController.text.trim();
    final newPass = _newController.text.trim();
    final confirm = _confirmController.text.trim();

    return current.isNotEmpty &&
        newPass.length >= 6 &&
        newPass == confirm &&
        newPass != current &&
        !_isSaving;
  }

  Future<void> _save() async {
    final labels = AppLabels.current;
    final validationError = _validate(labels);
    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.onChangePassword(
        _currentController.text.trim(),
        _newController.text.trim(),
      );

      if (!mounted) return;

      final success = result['success'] == true;
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _errorMessage = result['message'] as String? ??
              labels.passwordChangeFailed;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = labels.passwordChangeFailed;
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required dynamic theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        style: theme.inputTextStyle(),
        onChanged: (_) => setState(() => _errorMessage = null),
        decoration: theme.inputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.lock_outline,
              color: theme.defaultGray700Color, size: 20),
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: theme.default500Color,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

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
                    Icons.lock_outline,
                    color: theme.default700Color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  labels.changePassword,
                  style: theme.textLabelBold(color: theme.default700Color),
                ),
                const SizedBox(height: 20),
                _buildPasswordField(
                  controller: _currentController,
                  label: labels.currentPassword,
                  obscure: _obscureCurrent,
                  onToggle: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                  theme: theme,
                ),
                _buildPasswordField(
                  controller: _newController,
                  label: labels.newPassword,
                  obscure: _obscureNew,
                  onToggle: () =>
                      setState(() => _obscureNew = !_obscureNew),
                  theme: theme,
                ),
                _buildPasswordField(
                  controller: _confirmController,
                  label: labels.newPasswordConfirm,
                  obscure: _obscureConfirm,
                  onToggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  theme: theme,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: theme.panelDangerColor, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style:
                              theme.textCaption(color: theme.panelDangerColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 12),
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
                        onPressed: _canSave ? _save : null,
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
