import 'dart:convert';

import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/constants/url/api_hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/widgets/warning_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/external-applications-config/external_applications_config_cubit.dart';
import '../../contants/application_color.dart';
import '../../core/services/jwt_storage_service.dart';
import '../../core/utils/request_util.dart';
import '../../core/widgets/bottom_navigation_bar_widget.dart';
import '../../core/widgets/top_appbar_widget.dart';

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

  TextEditingController _titleController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  late FocusNode myFocusNode;

  Future<bool> create(String title, String detail) async {
    bool result = false;
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final url = ApiHamamSpaUrlConstants.addSuggestionComplaintUrl(
          externalApplicationConfig!.apiHamamspaUrl);
      final String token = await JwtStorageService.getToken() as String;

      var response = await RequestUtil.post(url, token: token, body: {
        "title": title,
        "details": detail,
      });
      final data = jsonDecode(response!.body);
      result = bool.parse(data["output"].toString());
    } catch (e) {
      print(e);
    } finally {
      return result;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    myFocusNode = FocusNode();
    _titleController.text = widget.title!;
    _messageController.text = widget.detail!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBarWidget(
          title: (widget.title == ""
              ? "Öneri Şikayet Oluştur"
              : "Öneri Şikayet Görüntüle")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                    child: TextFormField(
                      readOnly: (widget.title != "" ? true : false),
                      controller: _titleController,
                      focusNode: myFocusNode,
                      autofocus: false,
                      decoration: InputDecoration(
                        labelText: 'Başlık',
                        hintText: "Konu Başlığını Yazınız...",
                        labelStyle: TextStyle(
                            fontFamily: "Inter",
                            letterSpacing: 0,
                            color: ApplicationColor.primaryText),
                        alignLabelWithHint: true,
                        hintStyle: TextStyle(
                            fontFamily: "Inter",
                            letterSpacing: 2,
                            fontWeight: FontWeight.normal,
                            color: ApplicationColor.primaryHintText),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ApplicationColor.primaryText,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ApplicationColor.primaryText,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ApplicationColor
                                .error, //FlutterFlowTheme.of(context).error,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ApplicationColor.error,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      style: TextStyle(fontFamily: "Inter", letterSpacing: 0),
                      maxLength: 50,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      cursorColor: ApplicationColor
                          .primaryText, // FlutterFlowTheme.of(context).primaryText,
                      onChanged: (text) {
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(10, 20, 10, 0),
                    child: TextFormField(
                      controller: _messageController,
                      readOnly: (widget.title != "" ? true : false),
                      //focusNode: myFocusNode,
                      maxLines: null,
                      minLines: 10,
                      maxLength: 1000,
                      autofocus: false,
                      decoration: InputDecoration(
                        labelText: 'Öneri ve Şikayet',
                        hintText: "Öneri ve Şikayetizi Yazınız...",
                        labelStyle: TextStyle(
                            fontFamily: "Inter",
                            letterSpacing: 0,
                            color: ApplicationColor.primaryText),
                        alignLabelWithHint: true,
                        hintStyle: TextStyle(
                            fontFamily: "Inter",
                            letterSpacing: 2,
                            fontWeight: FontWeight.normal,
                            color: ApplicationColor.primaryHintText),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ApplicationColor.primaryText,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ApplicationColor.primaryText,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ApplicationColor
                                .error, //FlutterFlowTheme.of(context).error,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ApplicationColor.error,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      style: TextStyle(fontFamily: "Inter", letterSpacing: 0),
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      cursorColor: ApplicationColor
                          .primaryText, // FlutterFlowTheme.of(context).primaryText,
                      onChanged: (text) {
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ],
            ),
            if (widget.title == "") ...[
              const SizedBox(height: 20),
              // Butonlar
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BlocTheme.theme.defaultRed700Color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        "İptal",
                        style: TextStyle(
                            fontSize: 16,
                            color: BlocTheme.theme.defaultWhiteColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 50),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                              String title = _titleController.text.trim();
                              String detail = _messageController.text.trim();

                              if (title.isNotEmpty && detail.isNotEmpty) {
                                setState(() {
                                  _isSubmitting = true;
                                });

                                try {
                                  final result = await create(title, detail);
                                  // örnek sonuç kontrolü
                                  if (result == true) {
                                    _titleController.clear();
                                    _messageController.clear();
                                    await warningDialog(context,
                                        message: "Başarıyla gönderildi",
                                        path: BlocTheme.theme.attentionSvgPath);

                                    Navigator.pop(context, true);
                                  } else {
                                    await warningDialog(context,
                                        message:
                                            "Gönderim başarısz, lütfen daha sonra tekrar deneyiniz.",
                                        path: BlocTheme.theme.errorSvgPath);
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Hata oluştu: $e")),
                                  );
                                } finally {
                                  setState(() {
                                    _isSubmitting = false;
                                  });
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Lütfen tüm alanları doldurunuz")),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BlocTheme.theme.default500Color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        _isSubmitting ? "Gönderiliyor..." : "Gönder",
                        style: TextStyle(
                          fontSize: 16,
                          color: BlocTheme.theme.defaultBlackColor,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ]
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(tab: NavTab.home),
    );
  }
}
