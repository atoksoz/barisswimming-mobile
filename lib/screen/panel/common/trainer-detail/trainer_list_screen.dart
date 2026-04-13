import 'dart:convert';

import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/constants/url/randevu_al_url_constants.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:e_sport_life/core/widgets/star_rating_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/data/model/trainer_model.dart';
import 'package:e_sport_life/screen/panel/common/trainer-detail/trainer_detail_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TrainerListScreen extends StatefulWidget {
  const TrainerListScreen({Key? key}) : super(key: key);

  @override
  State<TrainerListScreen> createState() => _TrainerListScreenState();
}

class _TrainerListScreenState extends State<TrainerListScreen> {
  static const double _cardHeight = 55.0;

  late Future<List<TrainerModel>> _trainersFuture;

  @override
  void initState() {
    super.initState();
    _trainersFuture = _fetchTrainers();
  }

  Future<List<TrainerModel>> _fetchTrainers() async {
    try {
      final externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final url = RandevuAlUrlConstants.getAllTrainersUrl(
          externalConfig!.onlineReservation);
      final token = await JwtStorageService.getToken() as String;
      final response = await RequestUtil.get(url, token: token);
      final json = jsonDecode(response!.body) as Map<String, dynamic>;

      if (kDebugMode) {
        debugPrint('[TrainerList] URL: $url');
        final out = json['output'];
        if (out is List && out.isNotEmpty) {
          final first = out.first;
          if (first is Map<String, dynamic>) {
            debugPrint('[TrainerList] first trainer keys: ${first.keys.toList()}');
            debugPrint('[TrainerList] first trainer JSON:');
            debugPrint(const JsonEncoder.withIndent('  ').convert(first));
          }
        } else {
          debugPrint('[TrainerList] output is empty or not a list');
        }
      }

      return (json["output"] as List)
          .map((item) => TrainerModel.fromJson(item))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = AppLabels.current;

    return Scaffold(
      appBar: TopAppBarWidget(title: labels.trainerRoster),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<TrainerModel>>(
              future: _trainersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingIndicatorWidget());
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return _buildTrainerList(snapshot.data!);
                } else {
                  return const Center(child: NoDataTextWidget());
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(tab: NavTab.profile),
    );
  }

  Widget _buildTrainerList(List<TrainerModel> trainers) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;
    return ListView.builder(
      itemCount: trainers.length,
      itemBuilder: (context, index) {
        final data = trainers[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TrainerDetailScreen(
                  trainerId: data.id,
                  name: data.name,
                  duty: data.duty,
                  profession: data.profession,
                  explanation: data.explanation,
                  image: data.image,
                  facebookUrl: data.facebook,
                  instagramUrl: data.instagram,
                  tiktokUrl: data.tiktok,
                  twitterUrl: data.twitter,
                  youtubeUrl: data.youtube,
                  rate: data.rate,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: theme.defaultGray100Color,
              border: Border.all(color: theme.defaultGray200Color),
              borderRadius:
                  BorderRadius.all(Radius.circular(theme.panelCardRadius)),
            ),
            margin: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
            width: MediaQuery.sizeOf(context).width,
            height: _cardHeight,
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Container(
                    margin:
                        const EdgeInsetsDirectional.fromSTEB(20, 0, 10, 0),
                    width: MediaQuery.sizeOf(context).width,
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    data.name,
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style: theme.textBodyBold(
                                        color: theme.default900Color),
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
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    data.skillsLabel,
                                    textAlign: TextAlign.left,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textCaption(
                                        color: theme.defaultGray900Color),
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
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          StarRatingWidget(rate: data.rate_),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels.rating,
                        style: theme.textMini(
                            color: theme.defaultBlackColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
