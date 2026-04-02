import 'dart:convert';

import 'package:e_sport_life/core/constants/url/gym_training_url_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/external-applications-config/external_applications_config_cubit.dart';
import '../../contants/application_color.dart';
import '../../core/services/jwt_storage_service.dart';
import '../../core/utils/request_util.dart';
import '../../core/widgets/bottom_navigation_bar_widget.dart';
import '../../core/widgets/loading_indicator_widget.dart';
import '../../core/widgets/no_data_text_widget.dart';
import '../../core/widgets/top_appbar_widget.dart';

class Diet extends StatefulWidget {
  const Diet({Key? key}) : super(key: key);

  @override
  State<Diet> createState() => _DietState();
}

class _DietState extends State<Diet> {
  String dietName = "";
  String dietDetail = "";
  bool isLoading = true;

  Future<void> fetchMemberDiet() async {
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;

      final url = GymTrainingUrlConstants.getDietdDataUrl(
          externalApplicationConfig!.gymTraining);
      final String token = await JwtStorageService.getToken() as String;
      var response = await RequestUtil.get(url, token: token);
      final Map<String, dynamic> json = jsonDecode(response!.body);
      var result = jsonDecode(response.body)["output"];
      setState(() {
        dietName = result["name"].toString().toUpperCase();
        dietDetail = result["detail"];
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMemberDiet();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBarWidget(
        title: "Beslenme Bilgilerim",
      ),
      body: isLoading
          ? const Center(child: LoadingIndicatorWidget()) // 1. Yükleniyor
          : dietName == ""
              ? const Center(child: NoDataTextWidget()) // 2. Boş veri
              : Container(
                  // 3. Geçerli veri
                  margin:
                      const EdgeInsets.only(left: 10.0, right: 10.0, top: 20),
                  padding: const EdgeInsets.all(10.0),
                  height: MediaQuery.sizeOf(context).height -
                      (MediaQuery.sizeOf(context).height * 0.22),
                  child: ListView(
                    reverse: false,
                    children: <Widget>[
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    dietName,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontFamily: "Inter",
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w600,
                                      color: ApplicationColor.fourthText,
                                      fontSize: 24,
                                    ),
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
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      10, 10, 10, 0),
                                  child: Text(
                                    dietDetail,
                                    style: TextStyle(
                                      fontFamily: "Inter",
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w600,
                                      color: ApplicationColor.fourthText,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ].reversed.toList(),
                  ),
                ),
      bottomNavigationBar: BottomNavigationBarWidget(
        tab: NavTab.home,
      ),
    );
  }
}
