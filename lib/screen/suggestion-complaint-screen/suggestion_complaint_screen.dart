import 'dart:convert';

import 'package:e_sport_life/screen/suggestion-complaint-screen/suggestion_complaint_add_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../config/external-applications-config/external_applications_config_cubit.dart';
import '../../config/themes/bloc_theme.dart';
import '../../core/constants/url/api_hamam_spa_url_constants.dart';
import '../../core/services/jwt_storage_service.dart';
import '../../core/utils/request_util.dart';
import '../../core/widgets/bottom_navigation_bar_widget.dart';
import '../../core/widgets/loading_indicator_widget.dart';
import '../../core/widgets/no_data_text_widget.dart';
import '../../core/widgets/top_appbar_widget.dart';
import '../../data/model/suggestion_complaint_model.dart';

class SuggestionComplaint extends StatefulWidget {
  const SuggestionComplaint({Key? key}) : super(key: key);

  @override
  State<SuggestionComplaint> createState() => _SuggestionComplaintState();
}

class _SuggestionComplaintState extends State<SuggestionComplaint> {
  Future<List<SuggestionComplaintModel>> get() async {
    List<SuggestionComplaintModel> suggestionComplaintModel = [];

    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final url = ApiHamamSpaUrlConstants.getSuggestionComplaintUrl(
          externalApplicationConfig!.apiHamamspaUrl);
      final String token = await JwtStorageService.getToken() as String;

      var response = await RequestUtil.get(
        url,
        token: token,
      );

      final Map<String, dynamic> json = jsonDecode(response!.body);

      suggestionComplaintModel = (json["output"] as List)
          .map((item) => SuggestionComplaintModel.fromJson(item))
          .toList();
    } catch (e) {
      print(e);
    } finally {
      return suggestionComplaintModel;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBarWidget(
        title: "Öneri Şikayet Geçmişi",
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<List<SuggestionComplaintModel>>(
              future: get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // until data is fetched, show loader
                  return const Center(child: LoadingIndicatorWidget());
                } else if (snapshot.hasData && snapshot.data!.length > 0) {
                  final order = snapshot.data!;
                  return buildPosts(order);
                } else {
                  // if no data, show simple Text
                  return const Center(child: NoDataTextWidget());
                }
              },
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: BlocTheme.theme.default500Color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        SuggestionComplaintAdd(title: "", detail: "")),
              );
              if (result == true) {
                setState(() {});
              }
            },
            child: Text(
              "Öneri Şikayet Oluştur",
              style: TextStyle(
                fontSize: 18,
                color: BlocTheme.theme.defaultBlackColor,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        tab: NavTab.home,
      ),
    );
  }

  Widget buildPosts(List<SuggestionComplaintModel> memberExtract) {
    // ListView Builder to show data in a list
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 110),
      itemCount: memberExtract.length,
      itemBuilder: (context, index) {
        final data = memberExtract[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SuggestionComplaintAdd(
                    title: data.title,
                    detail: data.details), // sayfana göre ayarla
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  spreadRadius: 1,
                  color: Color.fromARGB(1, 249, 250, 251),
                ),
              ],
              color: BlocTheme.theme.defaultGray50Color,
              border: Border.all(color: Color.fromARGB(1, 249, 250, 251)),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            margin: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
            width: MediaQuery.sizeOf(context).width,
            height: 65,
            child: Row(
              children: [
                // ICON LEFT
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          BlocTheme.theme.suggestionSvgPath,
                          width: 36,
                          height: 36,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),

                // TITLE, DETAIL, DATE
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                textAlign: TextAlign.right,
                                data.title,
                                softWrap: false,
                                style: TextStyle(
                                  color: BlocTheme.theme.default900Color,
                                  fontFamily: "Inter",
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      Expanded(
                        child: Row(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                textAlign: TextAlign.left,
                                data.details.length > 30
                                    ? '${data.details.substring(0, 30)}...'
                                    : data.details,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                  color: BlocTheme.theme.defaultBlackColor,
                                  fontFamily: "Inter",
                                  letterSpacing: 0,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(right: 5),
                          child: Text(
                            data.createdDate,
                            textAlign: TextAlign.right,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              color: BlocTheme.theme.defaultBlackColor,
                              fontFamily: "Inter",
                              letterSpacing: 0,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ARROW ICON SAĞDA
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: BlocTheme.theme.default900Color,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
