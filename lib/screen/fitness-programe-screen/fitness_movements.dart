import 'dart:convert';

import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:e_sport_life/data/model/is_done_movement_model.dart';
import 'package:e_sport_life/data/model/movements_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/loading_indicator_widget.dart';
import '../../config/external-applications-config/external_applications_config_cubit.dart';
import '../../contants/application_color.dart';
import '../../core/constants/url/gym_training_url_constants.dart';
import '../../core/services/jwt_storage_service.dart';
import '../../core/utils/request_util.dart';
import '../../core/utils/shared-preferences/is_done_movement_cache_utils.dart';
import '../../core/widgets/bottom_navigation_bar_widget.dart';
import '../../core/widgets/section_selector_widget.dart';
import '../../core/widgets/top_appbar_widget.dart';
import '../../core/widgets/warning_dialog_widget.dart';
import 'fitness_movement_detail.dart';

class FitnessMovements extends StatefulWidget {
  const FitnessMovements(
      {Key? key,
      required this.programe_name,
      required this.day,
      required this.fitness_programe_id,
      required this.section_name,
      required this.is_old_programe,
      this.description})
      : super(key: key);

  final String programe_name;
  final String day;
  final String fitness_programe_id;
  final String section_name;
  final bool is_old_programe;
  final String? description;

  @override
  State<FitnessMovements> createState() => _FitnessMovementsState();
}

class _FitnessMovementsState extends State<FitnessMovements> {
  String get _infoMessage {
    final raw = widget.description?.trim() ?? '';
    if (raw.isEmpty || raw.toLowerCase() == 'null') {
      return '';
    }
    return raw;
  }
  String selectedSectionId = '';
  List<MovementsModel> allMovements = [];
  List<MovementsModel> filteredMovements = [];
  Future<List<MovementsModel>>? movementsFuture;

  Future<List<MovementsModel>> fetchFitnessMovements() async {
    List<MovementsModel> movements = [];

    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;

      final fitnessProgrameUrl =
          GymTrainingUrlConstants.getFitnessMovementsByDayAndSectionUrl(
        externalApplicationConfig!.gymTraining,
        widget.day,
        widget.fitness_programe_id,
      );

      final String token = await JwtStorageService.getToken() as String;
      var response = await RequestUtil.get(fitnessProgrameUrl, token: token);
      var body = json.decode(response!.body);

      movements = List<MovementsModel>.from(
        (body["output"]["data"] as List).map((e) => MovementsModel.fromJson(e)),
      );

      // ✅ Cache'den bugüne ait "is_done" verilerini al
      final List<IsDoneMovementModel> cachedDoneMovements =
          await loadMovementsFromCache(widget.day);

      // ✅ `MovementsModel` içine `isDone` alanını eşle
      for (var m in movements) {
        final match = cachedDoneMovements.firstWhere(
          (c) => c.fitnessMovementId == m.fitness_movement_id,
          orElse: () => IsDoneMovementModel(
            fitnessMovementId: '',
            day: '',
            isDone: false,
          ),
        );
        m.isDone = match.fitnessMovementId.isNotEmpty ? match.isDone : false;
      }

      allMovements = movements;
      filteredMovements = movements;
    } catch (e) {
      print(e);
    }

    return filteredMovements;
  }

  @override
  void initState() {
    super.initState();
    movementsFuture = fetchFitnessMovements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBarWidget(title: widget.programe_name),
      body: FutureBuilder<List<MovementsModel>>(
        future: movementsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicatorWidget());
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Column(
              children: [
                const SizedBox(height: 10),
                _buildHeader(filteredMovements.length),
                const SizedBox(height: 20),
                SectionSelector(
                  movements: allMovements,
                  selectedSectionId: selectedSectionId,
                  onSectionChanged: (newId) {
                    setState(() {
                      selectedSectionId = newId;
                      filteredMovements = newId.isEmpty
                          ? allMovements
                          : allMovements
                              .where((m) => m.section_id == newId)
                              .toList();
                    });
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(child: buildPosts(filteredMovements)),
              ],
            );
          } else {
            return const Center(child: NoDataTextWidget());
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBarWidget(tab: NavTab.home),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      decoration: BoxDecoration(
        color: ApplicationColor.primaryBoxBackground,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      height: 60,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "${widget.section_name} ($count hareket)",
                style: TextStyle(
                  color: BlocTheme.theme.default900Color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          if (_infoMessage.isNotEmpty) ...[
            IconButton(
              onPressed: () {
                if (_infoMessage.isEmpty) {
                  return;
                }
                warningDialog(
                  context,
                  message: _infoMessage,
                );
              },
              icon: Icon(
                Icons.info_outline,
                color: BlocTheme.theme.default900Color,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget buildPosts(List<MovementsModel> movements) {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: movements.length,
      itemBuilder: (context, index) {
        final data = movements[index];

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FitnessMovementDetail(
                    filteredMovements: filteredMovements,
                    fitness_programe_id: data.fitness_movement_id,
                    is_old_programe: widget.is_old_programe),
              ),
            ).then((shouldReload) {
              if (shouldReload == true) {
                setState(() {
                  // Yenileme işlemi, örneğin verileri tekrar yükle
                });
              }
            });
          },
          child: Card(
            color: BlocTheme.theme.defaultPuple50Color,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  if (data.default_image_url != null &&
                      data.default_image_url != "null" &&
                      data.default_image_url!.isNotEmpty) ...[
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.transparent, // Arka plan rengi
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.network(
                          (data.default_image_url != null &&
                                  data.default_image_url != "null" &&
                                  data.default_image_url!.isNotEmpty)
                              ? data.default_image_url!
                              : '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: Colors.transparent,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.broken_image, // veya Icons.fastfood vs.
                              size: 40,
                              color: BlocTheme.theme.default900Color,
                            ),
                          ),
                        ),
                      ),
                    )
                  ] else
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.transparent, // Arka plan rengi
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Container(
                          color: Colors.transparent,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.broken_image, // veya Icons.fastfood vs.
                            size: 40,
                            color: BlocTheme.theme.default900Color,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.fitness_movement_name ?? "-",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: BlocTheme.theme.defaultBlackColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                          style: TextStyle(
                              fontSize: 15,
                            color: BlocTheme.theme.default900Color,
                              fontFamily: 'Inter',
                            ),
                            children: [
                              TextSpan(
                                text: 'Set',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const TextSpan(text: ' : '),
                              TextSpan(
                                text: '${data.set}x${data.repeat}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (data.default_video != null &&
                            data.default_video!.isNotEmpty &&
                            data.default_video != "null")
                          Text(
                            "Video mevcut",
                            style: TextStyle(
                              fontSize: 14,
                              color: BlocTheme.theme.defaultRed700Color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        (data.isDone == true
                            ? Icons.check
                            : Icons.chevron_right_outlined),
                        color: BlocTheme.theme.default900Color,
                        size: 32,
                      ),
                    ],
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
