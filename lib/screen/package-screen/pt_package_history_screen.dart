import 'dart:convert';

import 'package:e_sport_life/data/model/package_model.dart';
import 'package:e_sport_life/data/model/my_resarvation_now_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../config/external-applications-config/external_applications_config_cubit.dart';
import '../../config/themes/bloc_theme.dart';
import '../../config/user-config/user_config_cubit.dart';
import '../../contants/application_color.dart';
import '../../core/constants/url/hamam_spa_url_constants.dart';
import '../../core/constants/url/randevu_al_url_constants.dart';
import '../../core/services/jwt_storage_service.dart';
import '../../core/utils/request_util.dart';
import '../../core/widgets/bottom_navigation_bar_widget.dart';
import '../../core/widgets/loading_indicator_widget.dart';
import '../../core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:e_sport_life/screen/package-screen/pt_package_history_detail_screen.dart';
import 'pt_trainer_list_screen.dart';

class PtPackageHistory extends StatefulWidget {
  final int initialTab;
  const PtPackageHistory({Key? key, this.initialTab = 0}) : super(key: key);

  @override
  State<PtPackageHistory> createState() => _PtPackageHistoryState();
}

class _PtPackageHistoryState extends State<PtPackageHistory> {
  String memberId = "";
  late int selectedTab;

  Future<void> getMemberId() async {
    try {
      await context.read<UserConfigCubit>().loadUserConfig();
      final userConfig = await context.read<UserConfigCubit>().state;

      if (userConfig != null) {
        setState(() {
          memberId = userConfig.memberId;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List<PackageModel>> fetchOrderProductData() async {
    List<PackageModel> packageModel = [];

    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;

      final extractUrl = HamamSpaUrlConstants.getActivePtMemberRegisterUrl(
          externalApplicationConfig!.hamamspaApiUrl);

      final String token = await JwtStorageService.getToken() as String;
      var response = await RequestUtil.get(extractUrl, token: token);
      final List body = json.decode(response!.body)["output"];
      packageModel = body.map((e) => PackageModel.fromJson(e)).toList();
    } catch (e) {
      print(e);
    } finally {
      return packageModel;
    }
  }

  Future<List<MyResarvationNowModel>> fetchMyResarvations() async {
    List<MyResarvationNowModel> reservations = [];
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final resarvationUrl = RandevuAlUrlConstants.getMyResarvationNowListUrl(
          externalApplicationConfig!.onlineReservation);
      final String token = await JwtStorageService.getToken() as String;
      var response = await RequestUtil.get("$resarvationUrl?&type=PT", token: token);
      final Map<String, dynamic> json = jsonDecode(response!.body);

      reservations = (json["output"] as List)
          .map((item) => MyResarvationNowModel.fromJson(item))
          .toList();
    } catch (e) {
      print("Error fetching PT reservations: $e");
    } finally {
      return reservations;
    }
  }

  @override
  void initState() {
    selectedTab = widget.initialTab;
    getMemberId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBarWidget(
        title: "Personal Training",
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PtPackageHistoryDetailScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.info_outline,
              color: Color.fromARGB(255, 55, 80, 0),
              size: 36,
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(
                top: 10.0, bottom: 0.0, right: 20, left: 20),
            width: MediaQuery.sizeOf(context).width,
            height: 50,
            alignment: AlignmentDirectional.center,
            child: Row(children: [
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
                                    ? BlocTheme.theme.default900Color
                                    : Color.fromARGB(1, 249, 250, 251))),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        margin: EdgeInsetsDirectional.fromSTEB(0, 0, 20, 0),
                        alignment: Alignment.center,
                        child: Text(
                          "Randevu Oluştur",
                          style: TextStyle(
                              color: BlocTheme.theme.default900Color,
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
                                    ? BlocTheme.theme.default900Color
                                    : Color.fromARGB(1, 249, 250, 251))),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        margin: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        alignment: Alignment.center,
                        child: Text(
                          "Randevularım",
                          style: TextStyle(
                              color: BlocTheme.theme.default900Color,
                              fontFamily: "Inter",
                              letterSpacing: 0,
                              fontWeight: FontWeight.w600,
                              fontSize: 18),
                        ),
                      ))),
            ]),
          ),
          Expanded(
            child: selectedTab == 0
                ? FutureBuilder<List<PackageModel>>(
                    future: fetchOrderProductData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: LoadingIndicatorWidget());
                      } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        final order = snapshot.data!;
                        return buildPtPackages(order);
                      } else {
                        return const Center(child: NoDataTextWidget());
                      }
                    },
                  )
                : FutureBuilder<List<MyResarvationNowModel>>(
                    future: fetchMyResarvations(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: LoadingIndicatorWidget());
                      } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return buildMyResarvations(snapshot.data!);
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

  Widget buildPtPackages(List<PackageModel> memberExtract) {
    return ListView.builder(
      itemCount: memberExtract.length,
      itemBuilder: (context, index) {
        final data = memberExtract[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PtTrainerList(
                  employeeId: data.employee_id,
                  memberRegisterId: data.member_register_id,
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
                )
              ],
              color: ApplicationColor.primaryBoxBackground,
              border: Border.all(color: Color.fromARGB(1, 249, 250, 251)),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            margin: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
            width: MediaQuery.sizeOf(context).width,
            height: 70,
            child: Row(
              children: [
                Expanded(
                  flex: 9,
                  child: Container(
                    margin: EdgeInsetsDirectional.fromSTEB(20, 5, 0, 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data.member_type,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(
                            color: BlocTheme.theme.default900Color,
                            fontFamily: "Inter",
                            letterSpacing: 0,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Kalan: ${data.remain_quantity} adet",
                          style: TextStyle(
                            color: BlocTheme.theme.default900Color,
                            fontFamily: "Inter",
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: EdgeInsetsDirectional.fromSTEB(0, 5, 10, 5),
                    child: Icon(
                      Icons.chevron_right_outlined,
                      color: BlocTheme.theme.default900Color,
                      size: 36.0,
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
    return ListView.builder(
      itemCount: model.length,
      itemBuilder: (context, index) {
        final data = model[index];

        // Parse date and time to check if it's in the future
        bool isFuture = false;
        try {
          DateTime resDate = DateTime.parse(data.date);
          List<String> timeParts = data.time.split(':');
          resDate = DateTime(resDate.year, resDate.month, resDate.day,
              int.parse(timeParts[0]), int.parse(timeParts[1]));
          isFuture = resDate.isAfter(DateTime.now());
        } catch (e) {}

        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                spreadRadius: 1,
                color: const Color.fromARGB(1, 249, 250, 251),
              )
            ],
            color: ApplicationColor.primaryBoxBackground,
            border: Border.all(color: const Color.fromARGB(1, 249, 250, 251)),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          margin: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      data.employee_name,
                      style: TextStyle(
                        color: BlocTheme.theme.default900Color,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  if (data.deleted_at != "")
                    Text(
                      "İptal Edildi",
                      style: TextStyle(
                        color: BlocTheme.theme.defaultRed700Color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 16, color: BlocTheme.theme.default900Color),
                  const SizedBox(width: 5),
                  Text(
                    DateFormat('dd.MM.yyyy').format(DateTime.parse(data.date)),
                    style: TextStyle(
                        color: BlocTheme.theme.default900Color, fontSize: 14),
                  ),
                  const SizedBox(width: 15),
                  Icon(Icons.access_time,
                      size: 16, color: BlocTheme.theme.default900Color),
                  const SizedBox(width: 5),
                  Text(
                    data.time,
                    style: TextStyle(
                        color: BlocTheme.theme.default900Color, fontSize: 14),
                  ),
                ],
              ),
              if (isFuture && data.deleted_at == "") ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: BlocTheme.theme.defaultRed700Color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: BlocTheme.theme.defaultRed700Color),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: BlocTheme.theme.defaultRed700Color, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Randevu iptalini sadece PT yapabilir.",
                          style: TextStyle(
                            color: BlocTheme.theme.defaultRed700Color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
