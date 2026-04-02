/*
  Authors : flutter_ninja (Flutter Ninja)
  Website : https://codecanyon.net/user/flutter_ninja/
  App Name : Fitness Flutter Template
  This App Template Source code is licensed as per the
  terms found in the Website https://codecanyon.net/licenses/standard/
  Copyright and Good Faith Purchasers © 2022-present flutter_ninja.
*/
import 'dart:convert';

import 'package:e_sport_life/core/constants/url/gym_training_url_constants.dart';
import 'package:e_sport_life/data/model/measurement_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/external-applications-config/external_applications_config_cubit.dart';
import '../../config/mobile-app-settings/mobile_app_settings.dart';
import '../../config/mobile-app-settings/mobile_app_settings_cubit.dart';
import '../../config/themes/bloc_theme.dart';
import '../../contants/application_color.dart';
import '../../core/services/jwt_storage_service.dart';
import '../../core/utils/request_util.dart';
import '../../core/widgets/bottom_navigation_bar_widget.dart';
import '../../core/widgets/loading_indicator_widget.dart';
import '../../core/widgets/no_data_text_widget.dart';
import '../../core/widgets/top_appbar_widget.dart';
import './measurement_add_screen.dart';
import './measurement_screen.dart';

class MeasurementHistory extends StatefulWidget {
  const MeasurementHistory({Key? key}) : super(key: key);

  @override
  State<MeasurementHistory> createState() => _MeasurementHistoryState();
}

class _MeasurementHistoryState extends State<MeasurementHistory> {
  FocusNode _focusNode = FocusNode();
  late Future<List<MeasurementModel>> _measurementsFuture;

  Future<List<MeasurementModel>> fetchMeasurement() async {
    List<MeasurementModel> model = [];
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final gymTrainingUrl = GymTrainingUrlConstants.getMeasurementdDataUrl(
          externalApplicationConfig!.gymTraining);
      final String token = await JwtStorageService.getToken() as String;
      var response = await RequestUtil.get(gymTrainingUrl, token: token);
      final Map<String, dynamic> json = jsonDecode(response!.body);

      model = (json["output"] as List)
          .map((item) => MeasurementModel.fromJson(item))
          .toList();
    } catch (e) {
      print(e);
    } finally {
      return model;
    }
  }

  @override
  void initState() {
    super.initState();
    _measurementsFuture = fetchMeasurement();
  }

  void _reloadMeasurements() {
    setState(() {
      _measurementsFuture = fetchMeasurement();
    });
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
        title: "Ölçümlerim",
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<List<MeasurementModel>>(
              future: _measurementsFuture,
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
          // Ölçüm ekleme butonu (sadece allowMeasurementCreate aktifse)
          BlocBuilder<MobileAppSettingsCubit, MobileAppSettings?>(
            builder: (context, settings) {
              if (settings?.allowMeasurementCreate == true) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MeasurementAddScreen(),
                        ),
                      ).then((_) {
                        // Ölçüm eklendikten sonra listeyi yenile
                        _reloadMeasurements();
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            spreadRadius: 1,
                            color: const Color.fromARGB(1, 249, 250, 251),
                          )
                        ],
                        color: BlocTheme.theme.defaultWhiteColor,
                        border: Border.all(
                          color: BlocTheme.theme.default800Color,
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(25)),
                      ),
                      height: 50,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add,
                              size: 28,
                              color: BlocTheme.theme.default800Color,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ölçüm Ekle',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: BlocTheme.theme.default800Color,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        tab: NavTab.home,
      ),
    );
  }

  Widget buildPosts(List<MeasurementModel> measurements) {
    return ListView.builder(
      itemCount: measurements.length,
      itemBuilder: (context, index) {
        final data = measurements[index];
        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Measurement(
                  measurements: measurements,
                  selectedIndex: index,
                ),
              ),
            ).then((result) {
              // Eğer silme işlemi yapıldıysa (result == true), sayfayı yenile
              if (result == true) {
                _reloadMeasurements();
              }
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
            height: 50,
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  textAlign: TextAlign.left,
                                  data.formattedDate,
                                  softWrap: false,
                                  style: TextStyle(
                                    color: ApplicationColor.fourthText,
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
                        Expanded(
                          child: Row(
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Tarihli Ölçüm",
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                    fontFamily: "Inter",
                                    letterSpacing: 0,
                                    fontSize: 12,
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
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsetsDirectional.fromSTEB(5, 8, 0, 0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.chevron_right_outlined,
                          color: ApplicationColor.fourthText,
                          size: 36.0,
                          semanticLabel: 'Profilim',
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
