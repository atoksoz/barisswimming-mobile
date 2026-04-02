import 'dart:convert';

import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/constants/url/randevu_al_url_constants.dart';
import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:e_sport_life/screen/package-screen/pt_appointment_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/external-applications-config/external_applications_config_cubit.dart';
import '../../contants/application_color.dart';
import '../../core/services/jwt_storage_service.dart';
import '../../core/utils/request_util.dart';
import '../../core/widgets/bottom_navigation_bar_widget.dart';
import '../../core/widgets/loading_indicator_widget.dart';
import '../../core/widgets/star_rating_widget.dart';
import '../../core/widgets/top_appbar_widget.dart';
import '../../data/model/trainer_model.dart';

class PtTrainerList extends StatefulWidget {
  final String? employeeId;
  final String? memberRegisterId;
  const PtTrainerList({Key? key, this.employeeId, this.memberRegisterId}) : super(key: key);

  @override
  State<PtTrainerList> createState() => _PtTrainerListState();
}

class _PtTrainerListState extends State<PtTrainerList> {
  Future<List<TrainerModel>> fetchTrainer() async {
    List<TrainerModel> trainerModel = [];
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;

      final randevuAlUrl = RandevuAlUrlConstants.getAllTrainersUrl(
          externalApplicationConfig!.onlineReservation);

      final String token = await JwtStorageService.getToken() as String;
      var response = await RequestUtil.get(randevuAlUrl, token: token);
      final Map<String, dynamic> json = jsonDecode(response!.body);

      trainerModel = (json["output"] as List)
          .map((item) => TrainerModel.fromJson(item))
          .toList();

      // Filter by employeeId if provided and not empty
      if (widget.employeeId != null && widget.employeeId!.isNotEmpty && widget.employeeId != "0") {
        trainerModel = trainerModel.where((t) => t.id.toString() == widget.employeeId).toList();
      }
    } catch (e) {
      print(e);
    } finally {
      return trainerModel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBarWidget(
        title: "Eğitmen Seçin",
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<List<TrainerModel>>(
              future: fetchTrainer(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingIndicatorWidget());
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return buildTrainerList(snapshot.data!);
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

  Widget buildTrainerList(List<TrainerModel> trainers) {
    return ListView.builder(
      itemCount: trainers.length,
      itemBuilder: (context, index) {
        final data = trainers[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PtAppointmentSelectionScreen(
                  trainerId: data.id,
                  trainerName: data.name,
                  memberRegisterId: widget.memberRegisterId,
                ),
              ),
            );
          },
          child: Container(
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
            width: MediaQuery.sizeOf(context).width,
            height: 70,
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Container(
                    margin: const EdgeInsetsDirectional.fromSTEB(20, 0, 10, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.name.toUpperCase(),
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(
                            color: ApplicationColor.fourthText,
                            fontFamily: "Inter",
                            letterSpacing: 0,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          data.duty,
                          textAlign: TextAlign.left,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: ApplicationColor.primaryText,
                            fontFamily: "Inter",
                            letterSpacing: 0,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsetsDirectional.fromSTEB(0, 5, 10, 5),
                    child: Icon(
                      Icons.chevron_right_outlined,
                      color: ApplicationColor.fourthText,
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
}
