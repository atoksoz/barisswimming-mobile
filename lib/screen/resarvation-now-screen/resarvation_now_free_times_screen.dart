import 'dart:convert';

import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../config/external-applications-config/external_applications_config_cubit.dart';
import '../../config/themes/bloc_theme.dart';
import '../../contants/application_color.dart';
import '../../core/constants/url/randevu_al_url_constants.dart';
import '../../core/services/jwt_storage_service.dart';
import '../../core/utils/request_util.dart';
import '../../core/widgets/bottom_navigation_bar_widget.dart';
import '../../core/widgets/custom_confirmation_dialog_widget.dart';
import '../../core/widgets/loading_indicator_widget.dart';
import '../../core/widgets/top_appbar_widget.dart';
import '../../core/widgets/warning_dialog_widget.dart';

class ResarvationNowFreeTimes extends StatefulWidget {
  final String id;
  final String dayNumber;
  final String day;
  final String planName;
  final String date;
  final String employeeName;
  const ResarvationNowFreeTimes(
      {Key? key,
      required this.id,
      required this.dayNumber,
      required this.day,
      required this.planName,
      required this.date,
      required this.employeeName})
      : super(key: key);

  @override
  State<ResarvationNowFreeTimes> createState() =>
      _ResarvationNowFreeTimesState();
}

class _ResarvationNowFreeTimesState extends State<ResarvationNowFreeTimes> {
  Future<List<String>> fetchFreeTimes() async {
    List<String> freeTimes = [];
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final resarvationUrl =
          RandevuAlUrlConstants.getServiceNowPlanGetFreeTimesForResarvationUrl(
              externalApplicationConfig!.onlineReservation,
              widget.dayNumber,
              widget.id);
      final String token = await JwtStorageService.getToken() as String;
      var response = await RequestUtil.get(resarvationUrl, token: token);
      var body = json.decode(response!.body)["output"];
      freeTimes = List.castFrom<dynamic, String>(body["avilable_times"]);
    } catch (e) {
    } finally {
      return freeTimes;
    }
  }

  Future<String> addResarvation(String time) async {
    String result = "true";
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final resarvationUrl =
          RandevuAlUrlConstants.getAddServiceNowPlanAddResarvationUrl(
              externalApplicationConfig!.onlineReservation);
      final String token = await JwtStorageService.getToken() as String;

      var response = await RequestUtil.post(resarvationUrl,
          body: {
            "service_now_plan_id": widget.id,
            "plan_date": widget.date,
            "plan_time": time
          },
          token: token);
      result = json.decode(response!.body)["output"];
    } catch (e) {
      result = "false";
    } finally {
      return result;
    }
  }

  @override
  void initState() {
    initializeDateFormatting();
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
        title: "Hızlı Randevu Oluştur",
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(
                top: 20.0, bottom: 10.0, right: 20, left: 20),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 2,
                    blurStyle: BlurStyle.outer,
                    color: ApplicationColor.primaryText,
                    offset: Offset.zero,
                    spreadRadius: 1,
                  )
                ],
                borderRadius: BorderRadius.all(Radius.circular(20))),
            width: MediaQuery.sizeOf(context).width,
            height: 55,
            child: Row(
              children: [
                Expanded(
                    flex: 4,
                    child: Container(
                      margin: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 5),
                      width: MediaQuery.sizeOf(context).width,
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.day + " - " + widget.employeeName,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow:
                                        TextOverflow.ellipsis, // burası önemli
                                    style: TextStyle(
                                      color: ApplicationColor.fourthText,
                                      fontFamily: "Inter",
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: fetchFreeTimes(),
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
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        tab: NavTab.home,
      ),
    );
  }

  Widget buildPosts(List<String> memberExtract) {
    // ListView Builder to show data in a list
    return ListView.builder(
      itemCount: memberExtract.length,
      itemBuilder: (context, index) {
        final data = memberExtract[index];
        return Material(
          color: Colors.transparent, // Veya istediğin arka plan rengi
          child: InkWell(
            borderRadius: BorderRadius.circular(20), // Aynı border radius
            onTap: () async {
              var message = widget.employeeName +
                  "\n" +
                  widget.planName +
                  " \n " +
                  widget.day +
                  " - " +
                  data +
                  " saatine randevu oluşturmak istiyor musunuz ?";
              var query = await customConfirmationDialog(
                context,
                message: message,
                svgPath: BlocTheme.theme.attentionSvgPath,
              );
              if (query == true) {
                var result = await addResarvation(data);
                if (result != "true") {
                  var message = result != ""
                      ? result
                      : 'Randevu oluşturulurken bir hata oluştu, lütfen daha sonra tekrar deneyiniz.';
                  warningDialog(
                    context,
                    message: message,
                    path: BlocTheme.theme.errorSvgPath,
                  );
                } else {
                  warningDialog(
                    context,
                    message:
                        "Randevu başarıyla oluşturuldu, randevularım sayfasından görüntüleyebilirsiniz.",
                  );
                  setState(() {});
                }
              }
            },
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      spreadRadius: 1,
                      color: Color.fromARGB(
                        1,
                        249,
                        250,
                        251,
                      ))
                ],
                color: ApplicationColor.primaryBoxBackground,
                border: Border.all(color: Color.fromARGB(1, 249, 250, 251)),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              margin: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
              width: MediaQuery.sizeOf(context).width,
              height: 60,
              child: Row(
                children: [
                  Expanded(
                      flex: 6,
                      child: Container(
                        margin: EdgeInsetsDirectional.fromSTEB(20, 5, 10, 5),
                        width: MediaQuery.sizeOf(context).width,
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                    textAlign: TextAlign.left,
                                    widget.planName,
                                    maxLines: 3,
                                    softWrap: true,
                                    style: TextStyle(
                                        color: ApplicationColor.fourthText,
                                        fontFamily: "Inter",
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16),
                                  ))
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                    textAlign: TextAlign.left,
                                    "Saat : " + data,
                                    maxLines: 3,
                                    softWrap: true,
                                    style: TextStyle(
                                        color: ApplicationColor.fourthText,
                                        fontFamily: "Inter",
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14),
                                  ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: EdgeInsetsDirectional.fromSTEB(20, 5, 10, 5),
                      width: MediaQuery.sizeOf(context).width,
                      child: Icon(
                        Icons.chevron_right_outlined,
                        color: ApplicationColor.fourthText,
                        size: 36.0,
                        semanticLabel:
                            'Text to announce in accessibility modes',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
