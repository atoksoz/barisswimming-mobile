import 'dart:convert';

import 'package:e_sport_life/core/widgets/custom_confirmation_dialog_widget.dart';
import 'package:e_sport_life/core/widgets/day_selector_widget.dart';
import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:e_sport_life/core/widgets/warning_dialog_widget.dart';
import 'package:e_sport_life/screen/package-screen/pt_package_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../config/external-applications-config/external_applications_config_cubit.dart';
import '../../config/themes/bloc_theme.dart';
import '../../contants/application_color.dart';
import '../../core/constants/url/randevu_al_url_constants.dart';
import '../../core/services/jwt_storage_service.dart';
import '../../core/utils/request_util.dart';
import '../../core/widgets/bottom_navigation_bar_widget.dart';
import '../../core/widgets/loading_indicator_widget.dart';
import '../../core/widgets/top_appbar_widget.dart';

class PtAppointmentSelectionScreen extends StatefulWidget {
  final String trainerId;
  final String trainerName;
  final String? memberRegisterId;

  const PtAppointmentSelectionScreen({
    Key? key,
    required this.trainerId,
    required this.trainerName,
    this.memberRegisterId,
  }) : super(key: key);

  @override
  State<PtAppointmentSelectionScreen> createState() =>
      _PtAppointmentSelectionScreenState();
}

class _PtAppointmentSelectionScreenState extends State<PtAppointmentSelectionScreen> {
  int selectedDay = DateTime.now().weekday;
  String dateRange = "";
  String selectedDateText = "";
  String selectedDateFormatted = "";
  String? currentPtPlanId;
  bool dateChanging = false;

  Future<List<String>> fetchFreeTimes() async {
    List<String> freeTimes = [];
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      
      final resarvationUrl = RandevuAlUrlConstants.getPtFreeTimesUrl(
          externalApplicationConfig!.onlineReservation,
          selectedDay.toString(),
          widget.trainerId);
          
      final String token = await JwtStorageService.getToken() as String;
      var response = await RequestUtil.get(resarvationUrl, token: token);
      
      if (response != null && response.statusCode == 200) {
        var body = json.decode(response.body)["output"];
        if (body != null && body["avilable_times"] != null) {
          freeTimes = List.castFrom<dynamic, String>(body["avilable_times"]);
          currentPtPlanId = body["service_now_plan_id"]?.toString();
        }
      }
    } catch (e) {
      print("Error fetching PT free times: $e");
    } finally {
      return freeTimes;
    }
  }

  Future<dynamic> addResarvation(String time) async {
    try {
      if (currentPtPlanId == null) {
        return "Randevu planı bulunamadı.";
      }

      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      
      final String token = await JwtStorageService.getToken() as String;
      
      final resarvationUrl =
          RandevuAlUrlConstants.getAddServiceNowPlanAddResarvationUrl(
              externalApplicationConfig!.onlineReservation);

      var response = await RequestUtil.post(resarvationUrl,
          body: {
            "service_now_plan_id": currentPtPlanId,
            "plan_date": selectedDateFormatted,
            "plan_time": time,
            "member_register_id": widget.memberRegisterId,
          },
          token: token);
      
      return json.decode(response!.body)["output"];
    } catch (e) {
      print("Error adding PT reservation: $e");
      return false;
    }
  }

  void updateDateInfo() {
    DateTime now = DateTime.now();
    
    setState(() {
      // Calculate date for selected day
      int daysToAdd = selectedDay - now.weekday;
      if (daysToAdd < 0) daysToAdd += 7;
      DateTime selectedDateTime = now.add(Duration(days: daysToAdd));
      
      selectedDateFormatted = DateFormat('yyyy-MM-dd').format(selectedDateTime);
      selectedDateText = "${selectedDateTime.day} ${DateFormat.MMMM("tr").format(selectedDateTime)} ${selectedDateTime.year} Randevu Listesi";
      
      // Date range for the week
      DateTime nextWeek = now.add(const Duration(days: 7));
      dateRange = "${now.day} ${DateFormat.MMMM("tr").format(now)} - ${nextWeek.day} ${DateFormat.MMMM("tr").format(nextWeek)} ${now.year}";
    });
  }

  @override
  void initState() {
    super.initState();
    updateDateInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBarWidget(
        title: "Randevu Günü & Saati",
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20.0, bottom: 10.0, right: 20, left: 20),
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
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            width: MediaQuery.sizeOf(context).width,
            height: 55,
            alignment: Alignment.center,
            child: Text(
              dateRange,
              style: TextStyle(
                color: ApplicationColor.fourthText,
                fontFamily: "Inter",
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: DaySelector(
              selectedDay: selectedDay,
              onDayChanged: (day) {
                setState(() {
                  selectedDay = day;
                  updateDateInfo();
                });
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 10.0, right: 20, left: 20),
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
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            width: MediaQuery.sizeOf(context).width,
            height: 35,
            alignment: Alignment.center,
            child: Text(
              selectedDateText,
              style: TextStyle(
                color: ApplicationColor.fourthText,
                fontFamily: "Inter",
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 5.0, right: 20, left: 20),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ApplicationColor.primaryBoxBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: ApplicationColor.fourthText, size: 20),
                const SizedBox(width: 10),
                Text(
                  widget.trainerName,
                  style: TextStyle(
                    color: ApplicationColor.fourthText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: fetchFreeTimes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingIndicatorWidget());
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return buildTimeList(snapshot.data!);
                } else {
                  return const Center(child: NoDataTextWidget());
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        tab: NavTab.home,
      ),
    );
  }

  Widget buildTimeList(List<String> times) {
    return ListView.builder(
      itemCount: times.length,
      itemBuilder: (context, index) {
        final time = times[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            color: ApplicationColor.primaryBoxBackground,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color.fromARGB(1, 249, 250, 251)),
          ),
          child: InkWell(
            onTap: () async {
              var message = "${widget.trainerName}\n" +
                  "${DateFormat('dd.MM.yyyy').format(DateTime.parse(selectedDateFormatted))} " +
                  "- $time saatine randevu oluşturmak istiyor musunuz ?";
              
              var query = await customConfirmationDialog(
                context,
                message: message,
                svgPath: BlocTheme.theme.attentionSvgPath,
              );

              if (query == true) {
                var result = await addResarvation(time);
                if (result == true) {
                  await warningDialog(
                    context,
                    message: "Randevu başarıyla oluşturuldu, randevularım sayfasından görüntüleyebilirsiniz.",
                  );
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PtPackageHistory(initialTab: 1),
                      ),
                      (route) => route.isFirst,
                    );
                  }
                } else {
                  var errorMsg = result is String ? result : 'Randevu oluşturulurken bir hata oluştu, lütfen daha sonra tekrar deneyiniz.';
                  warningDialog(
                    context,
                    message: errorMsg,
                    path: BlocTheme.theme.errorSvgPath,
                  );
                }
              }
            },
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, color: ApplicationColor.fourthText, size: 20),
                      const SizedBox(width: 15),
                      Text(
                        time,
                        style: TextStyle(
                          color: ApplicationColor.fourthText,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.chevron_right_outlined,
                    color: ApplicationColor.fourthText,
                    size: 30,
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
