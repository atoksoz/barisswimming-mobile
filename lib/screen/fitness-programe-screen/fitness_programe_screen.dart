import 'dart:convert';

import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/constants/url/gym_training_url_constants.dart';
import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:e_sport_life/screen/fitness-programe-screen/fitness_movements.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/loading_indicator_widget.dart';
import '../../config/external-applications-config/external_applications_config_cubit.dart';
import '../../contants/application_color.dart';
import '../../core/services/jwt_storage_service.dart';
import '../../core/utils/request_util.dart';
import '../../core/widgets/bottom_navigation_bar_widget.dart';
import '../../core/widgets/top_appbar_widget.dart';
import '../../data/model/fitness_programe_model.dart';
import '../../data/model/past_fitness_programe_model.dart';

class FitnessPrograme extends StatefulWidget {
  const FitnessPrograme({Key? key}) : super(key: key);

  @override
  State<FitnessPrograme> createState() => _FitnessProgrameState();
}

class _FitnessProgrameState extends State<FitnessPrograme> {
  Future<List<FitnessProgrameModel>>? _futureFitnessPrograme;

  int selectedTab = 0;
  bool showFitnessProgameDays = true;
  bool isOldPrograme = false;

  Future<List<FitnessProgrameModel>> fetchFitnessPrograme(
      int? fitnessProgrameId) async {
    List<FitnessProgrameModel> programe = [];
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final fitnessProgrameUrl = GymTrainingUrlConstants.getFitnessProgrameUrl(
          externalApplicationConfig!.gymTraining, fitnessProgrameId);
      final String token = await JwtStorageService.getToken() as String;

      var response = await RequestUtil.get(fitnessProgrameUrl, token: token);
      final List body = json.decode(response!.body)["output"];
      programe = body.map((e) => FitnessProgrameModel.fromJson(e)).toList();
    } catch (e) {
    } finally {
      return programe;
    }
  }

  Future<List<PastFitnessProgrameModel>> fetchPastFitnessProgrames() async {
    List<PastFitnessProgrameModel> programe = [];
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final fitnessProgrameUrl =
          GymTrainingUrlConstants.getPastFitnessProgramesUrl(
              externalApplicationConfig!.gymTraining);
      final String token = await JwtStorageService.getToken() as String;

      var response = await RequestUtil.get(fitnessProgrameUrl, token: token);
      final List body = json.decode(response!.body)["output"];
      programe = body.map((e) => PastFitnessProgrameModel.fromJson(e)).toList();
    } catch (e) {
    } finally {
      return programe;
    }
  }

  @override
  void initState() {
    super.initState();
    _futureFitnessPrograme = fetchFitnessPrograme(null);
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
        title: "Egzersiz Listem",
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(
                top: 20.0, bottom: 10.0, right: 20, left: 20),
            width: MediaQuery.sizeOf(context).width,
            height: 50,
            alignment: AlignmentDirectional.center,
            child: Row(children: [
              Expanded(
                  child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedTab = 0;
                          _futureFitnessPrograme = fetchFitnessPrograme(null);
                          showFitnessProgameDays = true;
                          isOldPrograme = false;
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
                          "Mevcut Listem",
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
                          showFitnessProgameDays = false;
                          selectedTab = 1;
                          isOldPrograme = true;
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
                          "Geçmiş Listem",
                          style: TextStyle(
                              color: ApplicationColor.fourthText,
                              fontFamily: "Inter",
                              letterSpacing: 0,
                              fontWeight: FontWeight.w600,
                              fontSize: 18),
                        ),
                      ))),
            ]),
          ),
          if (showFitnessProgameDays == true) ...[
            FutureBuilder<List<FitnessProgrameModel>>(
              future: _futureFitnessPrograme,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(); // veya loader koyabilirsin
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Align(
                    alignment: AlignmentDirectional(1, 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20, 10, 10, 0),
                            child: Text(
                              snapshot.data![0].programe_name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: "Inter",
                                letterSpacing: 0,
                                fontWeight: FontWeight.w600,
                                color: BlocTheme.theme.defaultBlackColor,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const SizedBox(); // veri yoksa hiçbir şey gösterme
                }
              },
            ),
          ],
          if (showFitnessProgameDays == true) ...[
            Expanded(
              child: FutureBuilder<List<FitnessProgrameModel>>(
                future: _futureFitnessPrograme,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // until data is fetched, show loader
                    return const Center(child: LoadingIndicatorWidget());
                  } else if (snapshot.hasData && snapshot.data!.length > 0) {
                    final daysData = snapshot.data!;
                    return buildDays(daysData);
                  } else {
                    // if no data, show simple Text
                    return const Center(child: NoDataTextWidget());
                  }
                },
              ),
            ),
          ],
          if (selectedTab == 1 && showFitnessProgameDays == false) ...[
            Expanded(
              child: FutureBuilder<List<PastFitnessProgrameModel>>(
                future: fetchPastFitnessProgrames(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // until data is fetched, show loader
                    return const Center(child: LoadingIndicatorWidget());
                  } else if (snapshot.hasData && snapshot.data!.length > 0) {
                    final daysData = snapshot.data!;
                    return buildPastProgrames(daysData);
                  } else {
                    // if no data, show simple Text
                    return const Center(child: NoDataTextWidget());
                  }
                },
              ),
            ),
          ]
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        tab: NavTab.home,
      ),
    );
  }

  Widget buildDays(List<FitnessProgrameModel> memberExtract) {
    // ListView Builder to show data in a list
    return ListView.builder(
      itemCount: memberExtract.length,
      itemBuilder: (context, index) {
        final data = memberExtract[index];
        return InkWell(
          onTap: () {
            print(data);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FitnessMovements(
                    programe_name: data.programe_name,
                    day: data.day,
                    fitness_programe_id: data.id,
                    section_name: data.day_text,
                    is_old_programe: isOldPrograme,
                    description: data.description),
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
            height: 60,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: EdgeInsetsDirectional.fromSTEB(10, 5, 0, 5),
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  textAlign: TextAlign.left,
                                  data.day_text,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(
                                    color: ApplicationColor.fourthText,
                                    fontFamily: "Inter",
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
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
                  flex: 6,
                  child: Container(
                    margin: EdgeInsetsDirectional.fromSTEB(20, 5, 10, 5),
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  textAlign: TextAlign.left,
                                  '', // Buraya içerik eklenebilir
                                  maxLines: 3,
                                  softWrap: true,
                                  style: TextStyle(
                                    color: ApplicationColor.fourthText,
                                    fontFamily: "Inter",
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
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
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Icon(
                                  Icons.chevron_right_outlined,
                                  color: BlocTheme.theme.default900Color,
                                  size: 36.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget buildPastProgrames(List<PastFitnessProgrameModel> memberExtract) {
    // ListView Builder to show data in a list
    return ListView.builder(
      itemCount: memberExtract.length,
      itemBuilder: (context, index) {
        final data = memberExtract[index];
        return InkWell(
          onTap: () async {
            print(data);
            int id = int.parse(data.id);
            setState(() {
              _futureFitnessPrograme = fetchFitnessPrograme(id);
              showFitnessProgameDays = true;
            });
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
            height: 60,
            child: Row(
              children: [
                Expanded(
                  flex: 9,
                  child: Container(
                    margin: EdgeInsetsDirectional.fromSTEB(10, 5, 0, 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data.programe_name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(
                            color: BlocTheme.theme.default900Color,
                            fontFamily: "Inter",
                            letterSpacing: 0,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Oluşturulma tarihi: ${data.created_at}",
                          style: TextStyle(
                            color: BlocTheme.theme.default900Color,
                            fontFamily: "Inter",
                            fontSize: 12,
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
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Icon(
                                  Icons.chevron_right_outlined,
                                  color: ApplicationColor.fourthText,
                                  size: 36.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
