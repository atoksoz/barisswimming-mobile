import 'dart:convert';

import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/constants/url/api_hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/data/model/suggestion_complaint_model.dart';
import 'package:e_sport_life/screen/panel/common/suggestion-complaint/suggestion_complaint_add_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class SuggestionComplaint extends StatefulWidget {
  const SuggestionComplaint({Key? key}) : super(key: key);

  @override
  State<SuggestionComplaint> createState() => _SuggestionComplaintState();
}

class _SuggestionComplaintState extends State<SuggestionComplaint> {
  Future<List<SuggestionComplaintModel>> _fetchList() async {
    List<SuggestionComplaintModel> items = [];
    try {
      final externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final url = ApiHamamSpaUrlConstants.getSuggestionComplaintUrl(
          externalConfig!.apiHamamspaUrl);
      final token = await JwtStorageService.getToken() as String;
      final response = await RequestUtil.get(url, token: token);
      final Map<String, dynamic> json = jsonDecode(response!.body);
      items = (json["output"] as List)
          .map((e) => SuggestionComplaintModel.fromJson(e))
          .toList();
    } catch (e) {
      print(e);
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

    return Scaffold(
      appBar: TopAppBarWidget(
        title: labels.suggestionComplaintHistory,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<List<SuggestionComplaintModel>>(
              future: _fetchList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingIndicatorWidget());
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return _buildList(snapshot.data!);
                } else {
                  return const Center(child: NoDataTextWidget());
                }
              },
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: theme.defaultWhiteColor,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.default500Color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const SuggestionComplaintAdd(
                        title: "", detail: "")),
              );
              if (result == true) setState(() {});
            },
            child: Text(
              labels.createSuggestionComplaint,
              style: theme.textLabelBold(color: theme.defaultBlackColor),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(tab: NavTab.home),
    );
  }

  Widget _buildList(List<SuggestionComplaintModel> items) {
    final theme = BlocTheme.theme;

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 110),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final data = items[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SuggestionComplaintAdd(
                    title: data.title, detail: data.details),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: theme.defaultGray50Color,
              border: Border.all(color: theme.defaultGray200Color),
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            margin: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
            width: MediaQuery.sizeOf(context).width,
            height: 65,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Center(
                    child: SvgPicture.asset(
                      theme.suggestionSvgPath,
                      width: 36,
                      height: 36,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            data.title,
                            softWrap: false,
                            style: theme.textBodyBold(
                                color: theme.default900Color),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            data.details.length > 30
                                ? '${data.details.substring(0, 30)}...'
                                : data.details,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: theme.textCaption(
                                color: theme.defaultBlackColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(right: 5),
                          child: Text(
                            data.createdDate,
                            textAlign: TextAlign.right,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: theme.textCaption(
                                color: theme.defaultBlackColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: theme.default900Color,
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
