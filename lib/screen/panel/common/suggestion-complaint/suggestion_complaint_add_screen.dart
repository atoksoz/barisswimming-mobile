import 'dart:convert';

import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/constants/url/api_hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/core/widgets/warning_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SuggestionComplaintAdd extends StatefulWidget {
  final String title;
  final String detail;

  const SuggestionComplaintAdd({
    Key? key,
    required this.title,
    required this.detail,
  }) : super(key: key);

  @override
  State<SuggestionComplaintAdd> createState() => _SuggestionComplaintAddState();
}

class _SuggestionComplaintAddState extends State<SuggestionComplaintAdd> {
  bool _isSubmitting = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  late FocusNode _focusNode;

  bool get _isViewMode => widget.title.isNotEmpty;

  Future<bool> _submit(String title, String detail) async {
    bool result = false;
    try {
      final externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final url = ApiHamamSpaUrlConstants.addSuggestionComplaintUrl(
          externalConfig!.apiHamamspaUrl);
      final token = await JwtStorageService.getToken() as String;
      final response = await RequestUtil.post(url, token: token, body: {
        "title": title,
        "details": detail,
      });
      final data = jsonDecode(response!.body);
      result = bool.parse(data["output"].toString());
    } catch (e) {
      print(e);
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _titleController.text = widget.title;
    _messageController.text = widget.detail;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

    return Scaffold(
      appBar: TopAppBarWidget(
        title: _isViewMode
            ? labels.viewSuggestionComplaint
            : labels.createSuggestionComplaint,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
              child: TextFormField(
                readOnly: _isViewMode,
                controller: _titleController,
                focusNode: _focusNode,
                autofocus: false,
                decoration: theme.inputDecoration(
                  labelText: labels.title,
                  hintText: labels.topicTitle,
                ),
                style: theme.inputTextStyle(),
                maxLength: 50,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                cursorColor: theme.defaultBlackColor,
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 20, 10, 0),
              child: TextFormField(
                controller: _messageController,
                readOnly: _isViewMode,
                maxLines: null,
                minLines: 10,
                maxLength: 1000,
                autofocus: false,
                decoration: theme.inputDecoration(
                  labelText: labels.suggestionAndComplaint,
                  hintText: labels.writeSuggestionComplaint,
                ),
                style: theme.inputTextStyle(),
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                cursorColor: theme.defaultBlackColor,
              ),
            ),
            if (!_isViewMode) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.defaultRed700Color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        labels.cancel,
                        style: theme.textBody(color: theme.defaultWhiteColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 50),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.default500Color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        _isSubmitting ? labels.submitting : labels.send,
                        style:
                            theme.textBody(color: theme.defaultBlackColor),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(tab: NavTab.home),
    );
  }

  Future<void> _handleSubmit() async {
    final labels = AppLabels.current;
    final title = _titleController.text.trim();
    final detail = _messageController.text.trim();

    if (title.isEmpty || detail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(labels.fillAllFields)),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final success = await _submit(title, detail);
      if (success) {
        _titleController.clear();
        _messageController.clear();
        await warningDialog(context,
            message: labels.sentSuccess,
            path: BlocTheme.theme.attentionSvgPath);
        if (mounted) Navigator.pop(context, true);
      } else {
        await warningDialog(context,
            message: labels.sendFailed,
            path: BlocTheme.theme.errorSvgPath);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
