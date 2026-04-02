import 'dart:convert';

import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../config/external-applications-config/external_applications_config_cubit.dart';
import '../../contants/application_color.dart';
import '../../core/constants/url/hamam_spa_url_constants.dart';
import '../../core/services/jwt_storage_service.dart';
import '../../core/utils/request_util.dart';
import '../../core/widgets/bottom_navigation_bar_widget.dart';
import '../../core/widgets/loading_indicator_widget.dart';
import '../../core/widgets/no_data_text_widget.dart';
import '../../core/widgets/top_appbar_widget.dart';

class ClosetSummary extends StatefulWidget {
  const ClosetSummary({Key? key}) : super(key: key);

  @override
  State<ClosetSummary> createState() => _ClosetSummaryState();
}

class _ClosetSummaryState extends State<ClosetSummary> {
  late Future<List<dynamic>> closetDataFuture;

  int occupiedCount = 0;
  int faultyCount = 0;
  int closetCount = 0;
  int emptyCount = 0;

  Future<List<dynamic>> fetchClosetData() async {
    List<dynamic> mergedList = [];

    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;

      final extractUrl = HamamSpaUrlConstants.getElectronicClosetSituationUrl(
          externalApplicationConfig!.hamamspaApiUrl);

      final String token = await JwtStorageService.getToken() as String;
      var response = await RequestUtil.get(extractUrl, token: token);
      //final List body = json.decode(response!.body)["output"];
      final Map<String, dynamic> json = jsonDecode(response!.body)["output"];
      mergedList = [
        ...(json['empty'] as List),
        ...(json['closet'] as List),
      ];

      setState(() {
        occupiedCount = (json['occupied'] as List).length;
        faultyCount = (json['faulty'] as List).length;
        closetCount = (json['closet'] as List).length;
        emptyCount = (json['empty'] as List).length;
      });
    } catch (e) {
      print(e);
    } finally {
      return mergedList;
    }
  }

  @override
  void initState() {
    //setState(() {});
    super.initState();
    closetDataFuture = fetchClosetData();
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
        title: "Dolap Listesi",
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(
                top: 20.0, bottom: 10.0, right: 20, left: 20),
            padding:
                const EdgeInsets.only(left: 20, top: 10, right: 10, bottom: 10),
            height: 130,
            decoration: BoxDecoration(
              color: ApplicationColor.primaryBoxBackground,
              border: Border.all(color: const Color.fromARGB(1, 249, 250, 251)),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  spreadRadius: 1,
                  color: Color.fromARGB(1, 249, 250, 251),
                )
              ],
            ),
            child: Row(
              children: [
                /// SOL TARAF - 2/3
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Dolap Doluluk",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Inter",
                          color: BlocTheme.theme.default600Color,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildLegendItem(
                        color: BlocTheme.theme.default900Color,
                        label: emptyCount.toString() + " Boş Elektronik Dolap",
                      ),
                      const SizedBox(height: 6),
                      _buildLegendItem(
                        color: BlocTheme.theme.defaultOrange500Color,
                        label:
                            occupiedCount.toString() + " Dolu Elektronik Dolap",
                      ),
                      const SizedBox(height: 6),
                      _buildLegendItem(
                        color: BlocTheme.theme.defaultBlue500Color,
                        label: closetCount.toString() + " Dolap",
                      ),
                    ],
                  ),
                ),

                /// SAĞ TARAF - 1/3
                Expanded(
                  flex: 1,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 30,
                          startDegreeOffset: -270,
                          sections: [
                            PieChartSectionData(
                              value: occupiedCount.toDouble(),
                              color: BlocTheme.theme.defaultOrange500Color,
                              showTitle: false,
                              radius: 15,
                            ),
                            PieChartSectionData(
                              value: emptyCount.toDouble(),
                              color: BlocTheme.theme.default900Color,
                              showTitle: false,
                              radius: 15,
                            ),
                            PieChartSectionData(
                              value: closetCount.toDouble(),
                              color: BlocTheme.theme.defaultBlue500Color,
                              showTitle: false,
                              radius: 15,
                            ),
                          ],
                          pieTouchData: PieTouchData(enabled: false),
                        ),
                        swapAnimationDuration: Duration.zero,
                      ),

                      /// Ortadaki toplam sayıyı yazdır
                      Text(
                        '${occupiedCount + emptyCount + closetCount}\nDolap',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: BlocTheme.theme.default900Color,
                          fontFamily: 'Inter',
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  "Boş Dolaplar",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          /// Burayı Expanded'den Flexible + SingleChildScrollView yapıyoruz
          Flexible(
            child: FutureBuilder<List<dynamic>>(
              future: closetDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: LoadingIndicatorWidget(),
                  );
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final order = snapshot.data!;
                  return SingleChildScrollView(
                    child: buildPosts(order, context),
                  );
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

  Widget buildPosts(List<dynamic> closetData, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double itemWidth = 90 + 16; // kutu genişliği + spacing
    int crossAxisCount = (screenWidth / itemWidth).floor();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 90 / 112,
        ),
        itemCount: closetData.length,
        itemBuilder: (context, index) {
          final data = closetData[index];

          return Container(
            width: 90,
            height: 112,
            decoration: BoxDecoration(
              color: ApplicationColor.primaryBoxBackground,
              border: Border.all(color: const Color.fromARGB(1, 249, 250, 251)),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  spreadRadius: 1,
                  color: Color.fromARGB(1, 249, 250, 251),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F3F3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      (data["type"] == "electronic_closet"
                          ? BlocTheme.theme.gateGreenSvgPath
                          : BlocTheme.theme.gateBlueSvgPath),
                      width: 50,
                      height: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data['name'] ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Inter",
                    color: BlocTheme.theme.default900Color,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 👇️ Yardımcı metod: renkli kare ve açıklama
  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontFamily: "Inter",
              color: BlocTheme.theme.default900Color,
            ),
          ),
        ),
      ],
    );
  }
}
