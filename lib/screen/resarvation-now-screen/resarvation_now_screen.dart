import 'dart:convert';

import 'package:e_sport_life/core/constants/url/randevu_al_url_constants.dart';
import 'package:e_sport_life/core/widgets/warning_dialog_widget.dart';
import 'package:e_sport_life/data/model/my_resarvation_now_model.dart';
import 'package:e_sport_life/screen/resarvation-now-screen/resarvation_now_free_times_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../config/external-applications-config/external_applications_config_cubit.dart';
import '../../config/themes/bloc_theme.dart';
import '../../contants/application_color.dart';
import '../../core/services/jwt_storage_service.dart';
import '../../core/utils/request_util.dart';
import '../../core/widgets/bottom_navigation_bar_widget.dart';
import '../../core/widgets/custom_confirmation_dialog_widget.dart';
import '../../core/widgets/day_selector_widget.dart';
import '../../core/widgets/loading_indicator_widget.dart';
import '../../core/widgets/no_data_text_widget.dart';
import '../../core/widgets/top_appbar_widget.dart';
import '../../data/model/resarvation_now_model.dart';

class ResarvationNow extends StatefulWidget {
  const ResarvationNow({Key? key}) : super(key: key);

  @override
  State<ResarvationNow> createState() => _ResarvationNowState();
}

class _ResarvationNowState extends State<ResarvationNow> {
  late Future<List<ResarvationNowModel>> resarvationNowList;

  int selectedTab = 0;
  int selectedDay = 0;
  bool dateChanging = false;
  bool reloadResarvations = false;
  String dateRange = "";
  String selectedDate = "";
  String selectedDateText = "";

  Future<List<MyResarvationNowModel>> fetchMyResarvationNowList() async {
    List<MyResarvationNowModel> myResarvationNow = [];
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final resarvationUrl = RandevuAlUrlConstants.getMyResarvationNowListUrl(
          externalApplicationConfig!.onlineReservation);
      final String token = await JwtStorageService.getToken() as String;
      var response = await RequestUtil.get(resarvationUrl, token: token);
      final Map<String, dynamic> json = jsonDecode(response!.body);

      myResarvationNow = (json["output"] as List)
          .map((item) => MyResarvationNowModel.fromJson(item))
          .toList();
    } catch (e) {
      print(e);
    } finally {
      return myResarvationNow;
    }
  }

  Future<bool> cancelResarvation(String service_now_plan_id) async {
    bool result = false;

    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final resarvationUrl = RandevuAlUrlConstants.getCancelResarvationNowUrl(
          externalApplicationConfig!.onlineReservation, service_now_plan_id);
      final String token = await JwtStorageService.getToken() as String;
      var response = await RequestUtil.delete(resarvationUrl, token: token);
      final Map<String, dynamic> json = jsonDecode(response!.body);
      result = json["output"];
    } catch (e) {
      print(e);
    } finally {
      return result;
    }
  }

  Future<List<ResarvationNowModel>> fetchResarvationNowList(
      int day_number) async {
    List<ResarvationNowModel> resarvationNow = [];
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final resarvationUrl =
          RandevuAlUrlConstants.getServiceNowPlanGetByDateNumberUrl(
              externalApplicationConfig!.onlineReservation,
              day_number.toString());
      final String token = await JwtStorageService.getToken() as String;
      var response = await RequestUtil.get(resarvationUrl, token: token);
      final Map<String, dynamic> json = jsonDecode(response!.body);

      resarvationNow = (json["output"] as List)
          .map((item) => ResarvationNowModel.fromJson(item))
          .toList();
    } catch (e) {
      print(e);
    } finally {
      return resarvationNow;
    }
  }

  Future<void> changeDay(int dayNumber) async {
    if (dateChanging == false) {
      setState(() {
        dateChanging = true;
        selectedDay = dayNumber;
      });

      List<ResarvationNowModel> resarvationNow =
          await fetchResarvationNowList(dayNumber);
      setState(() {
        try {
          resarvationNowList =
              resarvationNow as Future<List<ResarvationNowModel>>;
        } catch (e) {}

        if (resarvationNow.length == 0) {
          selectedDate = "";
        } else {
          DateTime d = DateTime.parse(resarvationNow[0].date);
          selectedDate = d.day.toString() +
              " " +
              DateFormat.MMMM("tr").format(d) +
              " " +
              d.year.toString();
          selectedDateText = selectedDate + " Hızlı Rezarvasyon Listesi";
        }
        dateChanging = false;
      });
    }
  }

  @override
  void initState() {
    initializeDateFormatting();
    super.initState();

    setState(() {
      DateTime now = DateTime.now();
      selectedDay = now.weekday;
      changeDay(selectedDay);
      DateTime nextWeek = now.add(Duration(days: 7));
      String startMonth = DateTime.now().month.toString();
      String endMonth = nextWeek.month.toString();
      dateRange = now.day.toString();
      if (startMonth == endMonth) {
        dateRange += " - " + nextWeek.day.toString();
        dateRange += DateFormat.MMMM("tr").format(nextWeek);
      } else {
        //dateRange += " - " + nextWeek.day.toString();
        dateRange += " " + DateFormat.MMMM("tr").format(now);
        dateRange += " - " +
            nextWeek.day.toString() +
            " " +
            DateFormat.MMMM("tr").format(nextWeek);
      }
      dateRange += " " + DateFormat.y("tr").format(nextWeek);

      selectedDate = now.day.toString() +
          " " +
          DateFormat.MMMM("tr").format(now) +
          " " +
          DateFormat.y("tr").format(now) +
          " Hızlı Randevu Listesi";
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    resarvationNowList = fetchResarvationNowList(selectedDay);
    return Scaffold(
      appBar: TopAppBarWidget(
        title: "Hızlı Randevu",
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(
                top: 20.0, bottom: 20.0, right: 20, left: 20),
            width: MediaQuery.sizeOf(context).width,
            height: 50,
            alignment: AlignmentDirectional.center,
            child: Row(
              children: [
                Expanded(
                    child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedTab = 0;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: (selectedTab == 0
                                  ? ApplicationColor.primary
                                  : Colors.white),
                              border: Border.all(
                                  color: (selectedTab == 1
                                      ? ApplicationColor.fourthText
                                      : Color.fromARGB(1, 249, 250, 251))),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          margin: EdgeInsetsDirectional.fromSTEB(0, 0, 20, 0),
                          alignment: Alignment.center,
                          child: Text(
                            "Randevu Oluştur",
                            style: TextStyle(
                                color: ApplicationColor.fourthText,
                                fontFamily: "Inter",
                                letterSpacing: 0,
                                fontWeight: FontWeight.w600,
                                fontSize: 18),
                          ),
                        ))),
                Expanded(
                    child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedTab = 1;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: (selectedTab == 1
                                  ? ApplicationColor.primary
                                  : Colors.white),
                              border: Border.all(
                                  color: (selectedTab == 0
                                      ? ApplicationColor.fourthText
                                      : Color.fromARGB(1, 249, 250, 251))),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          margin: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          alignment: Alignment.center,
                          child: Text(
                            "Randevularım",
                            style: TextStyle(
                                color: ApplicationColor.fourthText,
                                fontFamily: "Inter",
                                letterSpacing: 0,
                                fontWeight: FontWeight.w600,
                                fontSize: 18),
                          ),
                        ))),
              ],
            ),
          ),
          if (selectedTab == 0) ...[
            Container(
              margin: const EdgeInsets.only(
                  top: 0.0, bottom: 10.0, right: 20, left: 20),
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
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              width: MediaQuery.sizeOf(context).width,
              height: 55,
              child: Row(
                children: [
                  Expanded(
                      flex: 4,
                      child: Container(
                        margin: EdgeInsetsDirectional.fromSTEB(10, 5, 0, 5),
                        width: MediaQuery.sizeOf(context).width,
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                    textAlign: TextAlign.center,
                                    dateRange,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: TextStyle(
                                        color: ApplicationColor.fourthText,
                                        fontFamily: "Inter",
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18),
                                  ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  10, 0, 10, 10), // sol, üst, sağ, alt
              child: DaySelector(
                selectedDay: selectedDay,
                onDayChanged: (day) {
                  setState(() {
                    selectedDay = day;
                  });
                  changeDay(day);
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                  top: 0.0, bottom: 10.0, right: 20, left: 20),
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
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              width: MediaQuery.sizeOf(context).width,
              height: 35,
              child: Row(
                children: [
                  Expanded(
                      flex: 4,
                      child: Container(
                        margin: EdgeInsetsDirectional.fromSTEB(10, 5, 0, 5),
                        width: MediaQuery.sizeOf(context).width,
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                    textAlign: TextAlign.center,
                                    selectedDateText,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: TextStyle(
                                        color: ApplicationColor.fourthText,
                                        fontFamily: "Inter",
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14),
                                  ))
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
              child: FutureBuilder<List<ResarvationNowModel>>(
                future: resarvationNowList,
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
          ] else ...[
            Expanded(
              child: FutureBuilder<List<MyResarvationNowModel>>(
                future: fetchMyResarvationNowList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // until data is fetched, show loader
                    return const Center(child: LoadingIndicatorWidget());
                  } else if (snapshot.hasData && snapshot.data!.length > 0) {
                    final order = snapshot.data!;
                    return buildMyResarvations(order);
                  } else {
                    // if no data, show simple Text
                    return const Center(child: NoDataTextWidget());
                  }
                },
              ),
            )
          ]
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        tab: NavTab.home,
      ),
    );
  }

  Widget buildPosts(List<ResarvationNowModel> memberExtract) {
    // ListView Builder to show data in a list
    return ListView.builder(
      itemCount: memberExtract.length,
      itemBuilder: (context, index) {
        final data = memberExtract[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResarvationNowFreeTimes(
                  id: data.id.toString(),
                  dayNumber: selectedDay.toString(),
                  planName: data.resarvation_now_plan_name,
                  day: selectedDate,
                  date: data.date,
                  employeeName: data.employee_name,
                ),
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
                                  data.resarvation_now_plan_name,
                                  maxLines: 3,
                                  softWrap: true,
                                  style: TextStyle(
                                    color: ApplicationColor.fourthText,
                                    fontFamily: "Inter",
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  textAlign: TextAlign.left,
                                  data.employee_name,
                                  maxLines: 3,
                                  softWrap: true,
                                  style: TextStyle(
                                    color: ApplicationColor.fourthText,
                                    fontFamily: "Inter",
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: EdgeInsetsDirectional.fromSTEB(20, 5, 10, 5),
                    width: MediaQuery.sizeOf(context).width,
                    child: Icon(
                      Icons.chevron_right_outlined,
                      color: ApplicationColor.fourthText,
                      size: 36.0,
                      semanticLabel: 'Text to announce in accessibility modes',
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

  Widget buildMyResarvations(List<MyResarvationNowModel> model) {
    // ListView Builder to show data in a list
    return ListView.builder(
      itemCount: model.length,
      itemBuilder: (context, index) {
        final data = model[index];
        return Container(
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
              borderRadius: BorderRadius.all(Radius.circular(20))),
          margin: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 10),
          width: MediaQuery.sizeOf(context).width,
          height: 60,
          child: Row(
            children: [
              Expanded(
                  flex: 6,
                  child: Container(
                    margin: EdgeInsetsDirectional.fromSTEB(10, 5, 10, 5),
                    width: MediaQuery.sizeOf(context).width,
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(
                                textAlign: TextAlign.left,
                                data.resarvation_now_plan_name,
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
                              // Bu kısmı flexible yap
                              Expanded(
                                child: Text(
                                  textAlign: TextAlign.left,
                                  '${DateTime.parse(data.date).day} '
                                  '${DateFormat.MMMM("tr").format(DateTime.parse(data.date))} '
                                  '${data.time} - ${data.employee_name}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: ApplicationColor.fourthText,
                                    fontFamily: "Inter",
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 70,
                                // Buton için sabit genişlik
                                child: InkWell(
                                  onTap: () async {
                                    if (data.is_today == "1" &&
                                        data.deleted_at == "") {
                                      String text = DateTime.parse(data.date)
                                              .day
                                              .toString() +
                                          " " +
                                          DateFormat.MMMM("tr").format(
                                              DateTime.parse(data.date)) +
                                          " - " +
                                          data.time +
                                          " saatindeki " +
                                          data.resarvation_now_plan_name +
                                          " isimli randevuyu iptal etmek istiyor musunuz ?";
                                      var cancel =
                                          await customConfirmationDialog(
                                        context,
                                        message: text,
                                        svgPath:
                                            BlocTheme.theme.attentionSvgPath,
                                        confirmText: "Evet",
                                        cancelText: "Hayır",
                                      );
                                      if (cancel == true) {
                                        var result =
                                            await cancelResarvation(data.id);
                                        if (result == false) {
                                          warningDialog(
                                            context,
                                            message:
                                                "Randevu iptal edilirken bir hata oluştu, lütfen daha sonra tekrar deneyiniz",
                                          );
                                        } else {
                                          setState(() {});
                                        }
                                      }
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (data.deleted_at != "")
                                        Text(
                                          "İptal Edildi",
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: BlocTheme
                                                .theme.defaultRed700Color,
                                            fontFamily: "Inter",
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14,
                                          ),
                                        )
                                      else if (data.is_today == "1") ...[
                                        Text(
                                          "İptal Et",
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: BlocTheme
                                                .theme.defaultRed700Color,
                                            fontFamily: "Inter",
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.delete_outline,
                                          size: 18,
                                          color: BlocTheme
                                              .theme.defaultRed700Color,
                                        ),
                                        // Eğer SVG kullanıyorsan: SvgPicture.asset('assets/icons/delete.svg', width: 16)
                                      ]
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}
